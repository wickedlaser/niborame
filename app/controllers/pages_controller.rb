require 'faker'

class PagesController < ApplicationController
  def index
    @texts = 10.times.map do
      OpenStruct.new(
        title: Faker::Lorem.sentence,
        content: Faker::Lorem.paragraph,
        genre: ['濃厚', '淡麗', 'つけ麺', '汁なし'].sample # ジャンルをランダムに設定
      )
    end
  end
end
