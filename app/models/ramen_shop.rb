class RamenShop < ApplicationRecord
  SUPPORTED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze

  validates :name, presence: true
  validates :address, presence: true
  validates :introduction, presence: true

  has_one_attached :image

  validate :image_file_is_supported

  private

  def image_file_is_supported
    return unless image.attached?

    unless SUPPORTED_IMAGE_TYPES.include?(image.blob.content_type)
      errors.add(:image, 'はJPEG、PNG、WebP、GIF形式の画像を選択してください。')
    end

    errors.add(:image, 'は5MB以下のファイルを選択してください。') if image.blob.byte_size > 5.megabytes
  end
end
