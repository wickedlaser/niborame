class CreateRamenStores < ActiveRecord::Migration[7.1]
  def change
    create_table :ramen_stores do |t|
      t.string :title
      t.text :content
      t.string :genre
      t.string :address
      t.string :business_hours
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
