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
end
