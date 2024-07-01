require 'faker'
require 'securerandom'

class PagesController < ApplicationController
  def index
    @texts = 10.times.map do
      OpenStruct.new(
        id: SecureRandom.uuid,
        title: Faker::Lorem.sentence,
        content: Faker::Lorem.paragraph,
        genre: ['濃厚', '淡麗', 'つけ麺', '汁なし'].sample
      )
    end
    session[:texts] = @texts.map(&:to_h)
  end
end
