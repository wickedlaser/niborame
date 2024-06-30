class CreateRamenShops < ActiveRecord::Migration[7.1]
  def change
    create_table :ramen_shops do |t|
      t.string :name
      t.string :address
      t.string :place_id
      t.text :introduction

      t.timestamps
    end
  end
end
