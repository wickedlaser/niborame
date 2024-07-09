class ShoplistController < ApplicationController
  require 'google_places'

  def index
    @shops = RamenShop.all
  end

  def show
    @shop = RamenShop.find_by(id: params[:id])
    redirect_to root_path, alert: '店舗が見つかりません' if @shop.nil?

    return unless @shop.name.present?

    @place_details = search_place_by_name(@shop.name)
    return unless @place_details.present?

    # place_idを使用して詳細な情報を取得
    detailed_place = client.spot(@place_details.place_id)
    Rails.logger.info(detailed_place.opening_hours) # 営業時間をログに出力
    @shop.business_hours = if detailed_place.opening_hours.present? && detailed_place.opening_hours['weekday_text'].present?
                             weekday_translation = {
                               'Monday' => '月曜日',
                               'Tuesday' => '火曜日',
                               'Wednesday' => '水曜日',
                               'Thursday' => '木曜日',
                               'Friday' => '金曜日',
                               'Saturday' => '土曜日',
                               'Sunday' => '日曜日'
                             }
                             translated_hours = detailed_place.opening_hours['weekday_text'].map do |line|
                               weekday, hours = line.split(': ', 2)
                               "#{weekday_translation[weekday]}: #{hours}"
                             end
                             translated_hours.join("\n")
                           else
                             ''
                           end
    @shop.latitude = @place_details.lat
    @shop.longitude = @place_details.lng
    @shop.detail_image_url = get_image_url(@place_details.photos.first) if @place_details.photos.present?
    @shop.save
  end

  private

  def search_place_by_name(name)
    client = GooglePlaces::Client.new(ENV['GOOGLE_PLACES_API_KEY'])
    results = client.spots_by_query(name)
    results.first
  end

  def client
    @client ||= GooglePlaces::Client.new(ENV['GOOGLE_PLACES_API_KEY'])
  end

  def get_image_url(photo)
    photo.fetch_url(800) # 画像の幅を指定。必要に応じて変更してください。
  end
end
