class PagesController < ApplicationController
  def index
    @shops = RamenShop.all
    @shops.each do |shop|
      next unless shop.name.present? && shop.image_url.blank?

      place_details = search_place_by_name(shop.name)
      next unless place_details.present? && place_details.photos.present?

      photo = place_details.photos.first
      image_url = get_image_url(photo)
      puts "Setting image_url for #{shop.name}: #{image_url}"
      shop.update(image_url:)
    end
  end

  private

  def search_place_by_name(name)
    client = GooglePlaces::Client.new(ENV['GOOGLE_PLACES_API_KEY'])
    results = client.spots_by_query(name)
    results.first
  end

  def get_image_url(photo)
    photo.fetch_url(800)
  end

  def data_check
    @shops = RamenShop.all
    render json: @shops
  end
end
