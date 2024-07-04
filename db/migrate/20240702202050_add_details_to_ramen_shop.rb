class AddDetailsToRamenShop < ActiveRecord::Migration[7.1]
  def change
    add_column :ramen_shops, :title, :string
    add_column :ramen_shops, :content, :text
    add_column :ramen_shops, :genre, :string
    # add_column :ramen_shops, :address, :string # 既存のカラムを削除する
    add_column :ramen_shops, :business_hours, :string
    add_column :ramen_shops, :latitude, :float
    add_column :ramen_shops, :longitude, :float
  end
end
