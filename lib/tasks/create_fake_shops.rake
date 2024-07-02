require 'faker'

namespace :db do
  desc "Create fake shops"
  task create_fake_shops: :environment do
    10.times do
      RamenShop.create!(
        name: Faker::Restaurant.name,
        address: Faker::Address.full_address,
        introduction: Faker::Restaurant.description,
        title: Faker::Restaurant.name,
        content: Faker::Restaurant.description,
        genre: ['濃厚', '淡麗', 'つけ麺', '汁なし'].sample,
        business_hours: "11:00 - 22:00",
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude
      )
    end
  end
end


