FactoryBot.define do
  factory :ramen_store do
    title { 'MyString' }
    content { 'MyText' }
    genre { 'MyString' }
    address { 'MyString' }
    business_hours { 'MyString' }
    latitude { 1.5 }
    longitude { 1.5 }
  end
end
