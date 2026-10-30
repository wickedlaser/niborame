require 'rails_helper'

RSpec.describe RamenShop, type: :model do
  it 'requires a name, address, and introduction' do
    shop = described_class.new

    expect(shop).not_to be_valid
    expect(shop.errors.attribute_names).to include(:name, :address, :introduction)
  end

  it 'accepts supported image types up to 5 MB' do
    shop = described_class.new(name: '画像店', address: '大阪府', introduction: '紹介')
    shop.image.attach(io: StringIO.new('image bytes'), filename: 'shop.png', content_type: 'image/png')

    expect(shop).to be_valid
  end

  it 'rejects unsupported image types' do
    shop = described_class.new(name: '画像店', address: '大阪府', introduction: '紹介')
    shop.image.attach(io: StringIO.new('document bytes'), filename: 'menu.pdf', content_type: 'application/pdf')

    expect(shop).not_to be_valid
    expect(shop.errors[:image]).to include('はJPEG、PNG、WebP、GIF形式の画像を選択してください。')
  end

  it 'rejects images larger than 5 MB' do
    shop = described_class.new(name: '画像店', address: '大阪府', introduction: '紹介')
    shop.image.attach(
      io: StringIO.new('x' * (5.megabytes + 1)), filename: 'large.png', content_type: 'image/png'
    )

    expect(shop).not_to be_valid
    expect(shop.errors[:image]).to include('は5MB以下のファイルを選択してください。')
  end
end
