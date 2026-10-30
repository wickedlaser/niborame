require 'rails_helper'

RSpec.describe 'Admin shop management', type: :request do
  def configure_admin_credentials(username: 'admin-test', password: 'test-password')
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ADMIN_USERNAME').and_return(username)
    allow(ENV).to receive(:[]).with('ADMIN_PASSWORD').and_return(password)
  end

  def sign_in_admin
    configure_admin_credentials
    post admin_login_path, params: { username: 'admin-test', password: 'test-password' }
  end

  describe 'authentication' do
    it 'redirects an unauthenticated visitor to login' do
      get admin_shops_path

      expect(response).to redirect_to(admin_login_path)
    end

    it 'logs in with configured credentials and preserves the session' do
      sign_in_admin

      expect(response).to redirect_to(admin_shops_path)
      get admin_shops_path
      expect(response).to have_http_status(:success)
    end

    it 'rejects invalid credentials' do
      configure_admin_credentials
      post admin_login_path, params: { username: 'admin-test', password: 'wrong-password' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('ユーザー名またはパスワードが違います')
    end

    it 'disables login when credentials are not configured' do
      configure_admin_credentials(username: nil, password: nil)
      get admin_login_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('認証情報が未設定です')
      expect(response.body).to include('disabled')
    end
  end

  describe 'shop CRUD' do
    it 'creates a shop with the allowed attributes' do
      sign_in_admin
      post admin_shops_path, params: {
        ramen_shop: {
          name: '管理画面追加店', address: '大阪府大阪市', introduction: '煮干しの紹介',
          genre: '淡麗', business_hours: '11:00-15:00', google_place_id: 'place-id-test'
        }
      }

      shop = RamenShop.find_by!(name: '管理画面追加店')
      expect(response).to redirect_to(admin_shops_path)
      expect(shop.google_place_id).to eq('place-id-test')
      expect(shop.business_hours).to eq('11:00-15:00')
    end

    it 'uploads an image file and attaches it to the shop' do
      sign_in_admin
      upload = Rack::Test::UploadedFile.new(
        StringIO.new('test image bytes'), 'image/png', original_filename: 'ramen.png'
      )

      post admin_shops_path, params: {
        ramen_shop: {
          name: '画像アップロード店', address: '大阪府大阪市', introduction: '紹介', image: upload
        }
      }

      expect(response).to redirect_to(admin_shops_path)
      expect(RamenShop.find_by!(name: '画像アップロード店').image).to be_attached
    end

    it 'renders validation errors instead of saving invalid shops' do
      sign_in_admin
      shops_before_request = RamenShop.count
      post admin_shops_path, params: { ramen_shop: { name: '', address: '', introduction: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(RamenShop.count).to eq(shops_before_request)
    end

    it 'updates a shop' do
      sign_in_admin
      shop = RamenShop.create!(name: '編集前', address: '大阪府', introduction: '紹介')

      patch admin_shop_path(shop), params: { ramen_shop: { name: '編集後', genre: '濃厚' } }

      expect(response).to redirect_to(admin_shops_path)
      expect(shop.reload.attributes).to include('name' => '編集後', 'genre' => '濃厚')
    end

    it 'deletes a shop' do
      sign_in_admin
      shop = RamenShop.create!(name: '削除対象', address: '大阪府', introduction: '紹介')

      expect { delete admin_shop_path(shop) }.to change(RamenShop, :count).by(-1)
      expect(response).to redirect_to(admin_shops_path)
    end

    it 'removes an uploaded list image without removing the shop' do
      sign_in_admin
      shop = RamenShop.create!(name: '画像店', address: '大阪府', introduction: '紹介')
      shop.image.attach(io: StringIO.new('test image'), filename: 'shop.png', content_type: 'image/png')

      delete remove_image_admin_shop_path(shop)

      expect(response).to redirect_to(edit_admin_shop_path(shop))
      expect(shop.reload.image).not_to be_attached
    end

    it 'does not allow an unauthenticated visitor to delete a shop' do
      shop = RamenShop.create!(name: '保護対象', address: '大阪府', introduction: '紹介')

      expect { delete admin_shop_path(shop) }.not_to change(RamenShop, :count)
      expect(response).to redirect_to(admin_login_path)
    end
  end
end
