class ShoplistController < ApplicationController
  require 'json'
  require 'net/http'
  require 'uri'

  def index
    @shops = RamenShop.with_attached_image.order(:name)
    @genres = RamenShop.distinct.order(:genre).pluck(:genre).compact
    @query = params[:query].to_s.strip.first(100)
    @genre = params[:genre].to_s

    if @query.present?
      escaped_query = "%#{RamenShop.sanitize_sql_like(@query)}%"
      @shops = @shops.where('name ILIKE :query OR address ILIKE :query', query: escaped_query)
    end

    @shops = @shops.where(genre: @genre) if @genre.present? && @genres.include?(@genre)
  end

  def show
    @shop = RamenShop.find_by(id: params[:id])
    if @shop.nil?
      redirect_to root_path, alert: '店舗が見つかりません'
      return
    end

    @place_details = fetch_place_details(@shop.google_place_id) if @shop.google_place_id.present?
    response.headers['Cache-Control'] = 'private, no-store, max-age=0' if @shop.google_place_id.present?
    @display_address = @place_details&.dig('formattedAddress').presence || @shop.address
    @display_business_hours = @place_details&.dig('regularOpeningHours', 'weekdayDescriptions')&.join("\n").presence || @shop.business_hours
    @latitude = @place_details&.dig('location', 'latitude').presence || @shop.latitude
    @longitude = @place_details&.dig('location', 'longitude').presence || @shop.longitude
    @map_available = @latitude.present? && @longitude.present? && ENV['GOOGLE_MAPS_API_KEY'].present?
    @place_rating = @place_details&.dig('rating')
    @place_rating_count = @place_details&.dig('userRatingCount')
    @place_photos = build_place_photos(@place_details&.dig('photos'))
    map_query = "query=#{ERB::Util.url_encode(@shop.google_place_id.present? ? @shop.name : @shop.address)}"
    map_query += "&query_place_id=#{ERB::Util.url_encode(@shop.google_place_id)}" if @shop.google_place_id.present?
    @google_maps_url = @place_details&.dig('googleMapsUri').presence || "https://www.google.com/maps/search/?api=1&#{map_query}"
  end

  def place_photo
    response.headers['Cache-Control'] = 'private, no-store, max-age=0'
    @shop = RamenShop.find_by(id: params[:id])
    return head :not_found unless @shop&.google_place_id.present?

    photo_name = Rails.application.message_verifier(:place_photo).verified(params[:token], purpose: :place_photo)
    expected_prefix = "places/#{@shop.google_place_id}/photos/"
    return head :not_found unless photo_name.is_a?(String) && photo_name.start_with?(expected_prefix)

    api_key = ENV['GOOGLE_PLACES_API_KEY'].to_s
    return head :service_unavailable if api_key.blank?

    encoded_name = photo_name.split('/').map { |part| ERB::Util.url_encode(part) }.join('/')
    uri = URI("https://places.googleapis.com/v1/#{encoded_name}/media?#{URI.encode_www_form('maxWidthPx' => 1200, 'key' => api_key)}")
    photo_response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 8) do |http|
      http.request(Net::HTTP::Get.new(uri))
    end
    return head :bad_gateway unless photo_response.is_a?(Net::HTTPRedirection)

    photo_uri = URI.parse(photo_response['location'].to_s)
    unless photo_uri.scheme == 'https' && photo_uri.host&.end_with?('.googleusercontent.com')
      return head :bad_gateway
    end

    redirect_to photo_uri.to_s, allow_other_host: true, status: :found
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, URI::InvalidURIError, OpenSSL::SSL::SSLError => error
    Rails.logger.warn("Google Places photo lookup failed: #{error.class}")
    head :bad_gateway
  end

  private

  def build_place_photos(photos)
    expected_prefix = "places/#{@shop.google_place_id}/photos/"

    Array(photos).first(3).filter_map do |photo|
      photo_name = photo['name'].to_s
      next unless photo_name.start_with?(expected_prefix)

      attributions = Array(photo['authorAttributions']).filter_map do |attribution|
        name = attribution['displayName'].to_s
        uri = attribution['uri'].to_s
        uri = "https:#{uri}" if uri.start_with?('//')
        next if name.blank? && uri.blank?
        next if uri.present? && !uri.start_with?('https://')

        { name: name, uri: uri }
      end
      token = Rails.application.message_verifier(:place_photo).generate(photo_name, expires_in: 10.minutes, purpose: :place_photo)
      { url: place_photo_shoplist_path(@shop, token: token), attributions: attributions }
    end
  end

  def fetch_place_details(place_id)
    api_key = ENV['GOOGLE_PLACES_API_KEY'].to_s
    return if api_key.blank?

    encoded_place_id = ERB::Util.url_encode(place_id)
    uri = URI("https://places.googleapis.com/v1/places/#{encoded_place_id}?languageCode=ja")
    request = Net::HTTP::Get.new(uri)
    request['X-Goog-Api-Key'] = api_key
    request['X-Goog-FieldMask'] = 'formattedAddress,location,regularOpeningHours.weekdayDescriptions,googleMapsUri,rating,userRatingCount,photos'

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 5) do |http|
      http.request(request)
    end
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn("Google Places lookup failed: HTTP #{response.code}")
      return
    end

    JSON.parse(response.body)
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, JSON::ParserError, OpenSSL::SSL::SSLError => error
    Rails.logger.warn("Google Places lookup failed: #{error.class}")
    nil
  end
end
