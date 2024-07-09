class AddImageUrlToRamenShops < ActiveRecord::Migration[7.1]
  def change
    add_column :ramen_shops, :image_url, :string
  end
end
