class AddDetailsToRamenShops < ActiveRecord::Migration[6.1]
  def change
    add_column :ramen_shops, :google_place_id, :string unless column_exists?(:ramen_shops, :google_place_id)
  end
end
