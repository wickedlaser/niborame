require 'rails_helper'

RSpec.describe 'Shoplists', type: :request do
  describe 'GET /shoplist' do
    let!(:light_shop) do
      RamenShop.create!(name: '淡麗店', address: '大阪府大阪市', introduction: '淡麗の紹介', genre: '淡麗')
    end
    let!(:rich_shop) do
      RamenShop.create!(name: '濃厚店', address: '京都府京都市', introduction: '濃厚の紹介', genre: '濃厚')
    end

    it 'shows shops using their RamenShop attributes' do
      get '/shoplist'

      expect(response).to have_http_status(:success)
      expect(response.body).to include(light_shop.name, light_shop.introduction, rich_shop.name)
    end

    it 'filters the database results by genre' do
      get '/shoplist', params: { genre: '淡麗' }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(light_shop.name)
      expect(response.body).not_to include(rich_shop.name)
    end
  end

  describe 'GET /shoplist/:id' do
    let!(:shop) do
      RamenShop.create!(name: '詳細店', address: '大阪府大阪市', introduction: '詳細の紹介', genre: '淡麗')
    end

    it 'shows saved details without calling Google Places' do
      get "/shoplist/#{shop.id}"

      expect(response).to have_http_status(:success)
      expect(response.body).to include(shop.name, shop.address, shop.introduction)
      expect(response.body).to include('Googleマップで見る')
    end

    it 'redirects when the shop does not exist' do
      get '/shoplist/999999'

      expect(response).to redirect_to(root_path)
    end

    it 'keeps the uploaded list image separate from the detail image' do
      shop.update!(detail_image_url: 'https://images.example.com/detail.jpg')
      shop.image.attach(io: StringIO.new('list image bytes'), filename: 'list.png', content_type: 'image/png')

      get "/shoplist/#{shop.id}"

      expect(response).to have_http_status(:success)
      expect(response.body).to include('https://images.example.com/detail.jpg')
      expect(response.body).not_to include('/rails/active_storage/blobs/')
    end
  end
end
