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
    @display_address = @place_details&.dig('formattedAddress').presence || @shop.address
    @display_business_hours = @place_details&.dig('regularOpeningHours', 'weekdayDescriptions')&.join("\n").presence || @shop.business_hours
    @latitude = @place_details&.dig('location', 'latitude').presence || @shop.latitude
    @longitude = @place_details&.dig('location', 'longitude').presence || @shop.longitude
    @map_available = @latitude.present? && @longitude.present? && ENV['GOOGLE_MAPS_API_KEY'].present?
    map_query = "query=#{ERB::Util.url_encode(@shop.google_place_id.present? ? @shop.name : @shop.address)}"
    map_query += "&query_place_id=#{ERB::Util.url_encode(@shop.google_place_id)}" if @shop.google_place_id.present?
    @google_maps_url = @place_details&.dig('googleMapsUri').presence || "https://www.google.com/maps/search/?api=1&#{map_query}"
  end

  private

  def fetch_place_details(place_id)
    api_key = ENV['GOOGLE_PLACES_API_KEY'].to_s
    return if api_key.blank?

    encoded_place_id = ERB::Util.url_encode(place_id)
    uri = URI("https://places.googleapis.com/v1/places/#{encoded_place_id}?languageCode=ja")
    request = Net::HTTP::Get.new(uri)
    request['X-Goog-Api-Key'] = api_key
    request['X-Goog-FieldMask'] = 'formattedAddress,location,regularOpeningHours.weekdayDescriptions,googleMapsUri'

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 5) do |http|
      http.request(request)
    end
    return if !response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, JSON::ParserError, OpenSSL::SSL::SSLError => error
    Rails.logger.warn("Google Places lookup failed: #{error.class}")
    nil
  end
end
