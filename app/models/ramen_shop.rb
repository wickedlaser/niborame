class RamenShop < ApplicationRecord
  validates :name, presence: true
  validates :address, presence: true
  validates :introduction, presence: true

  has_one_attached :image

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
end
