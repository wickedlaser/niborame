require 'rails_helper'

RSpec.describe 'Google Places lookup', type: :request do
  let!(:shop) do
    RamenShop.create!(
      name: 'Place ID店', address: '登録済み住所', introduction: '手入力の紹介',
      google_place_id: 'place-id-test', business_hours: nil, latitude: nil, longitude: nil
    )
  end

  it 'uses live Place Details for the page without persisting Google content' do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOOGLE_PLACES_API_KEY').and_return('places-test-key')
    allow(ENV).to receive(:[]).with('GOOGLE_MAPS_API_KEY').and_return('maps-test-key')

    api_body = {
      formattedAddress: 'Google取得住所',
      location: { latitude: 35.0, longitude: 135.0 },
      regularOpeningHours: { weekdayDescriptions: ['月曜日: 11:00～15:00'] },
      googleMapsUri: 'https://maps.google.com/?place-id-test'
    }.to_json
    api_response = Net::HTTPOK.new('1.1', '200', 'OK')
    allow(api_response).to receive(:body).and_return(api_body)
    http = instance_double(Net::HTTP)
    allow(http).to receive(:request).and_return(api_response)
    allow(Net::HTTP).to receive(:start).and_yield(http)

    get shoplist_path(shop)

    expect(response).to have_http_status(:success)
    expect(response.body).to include('Google取得住所', '月曜日: 11:00～15:00', 'maps.google.com')
    expect(shop.reload.address).to eq('登録済み住所')
    expect(shop.reload.business_hours).to be_nil
    expect(shop.reload.latitude).to be_nil
    expect(shop.reload.longitude).to be_nil
  end

  it 'falls back to saved details when Google Places returns an error' do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOOGLE_PLACES_API_KEY').and_return('places-test-key')
    api_response = Net::HTTPServiceUnavailable.new('1.1', '503', 'Unavailable')
    http = instance_double(Net::HTTP)
    allow(http).to receive(:request).and_return(api_response)
    allow(Net::HTTP).to receive(:start).and_yield(http)

    get shoplist_path(shop)

    expect(response).to have_http_status(:success)
    expect(response.body).to include('登録済み住所', '営業時間は未登録です')
  end
end
