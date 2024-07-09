class AddDetailImageUrlToRamenShops < ActiveRecord::Migration[7.1]
  def change
    add_column :ramen_shops, :detail_image_url, :string
  end
end
