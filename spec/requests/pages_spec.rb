require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    it 'renders database-backed shops without requiring Places credentials' do
      shop = RamenShop.create!(
        name: 'テスト煮干し店',
        address: '大阪府大阪市',
        introduction: 'テスト用の紹介文',
        genre: '淡麗'
      )

      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(shop.name, shop.introduction, shop.genre)
    end
  end

  describe 'public policy pages' do
    it 'renders terms that incorporate Google Maps Platform terms' do
      get terms_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('利用規約', 'Google Maps Platform')
      expect(response.body).to include('https://cloud.google.com/maps-platform/terms')
    end

    it 'renders a privacy policy that describes Google data and contact handling' do
      get privacy_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('プライバシーポリシー', 'Google', 'お問い合わせ')
      expect(response.body).to include('https://policies.google.com/privacy')
    end
  end
end
