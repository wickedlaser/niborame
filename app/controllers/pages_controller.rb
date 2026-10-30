class PagesController < ApplicationController
  def index
    @shops = RamenShop.with_attached_image.order(:name)
    @genres = @shops.map(&:genre).compact_blank.uniq.sort
  end

  private

  def data_check
    @shops = RamenShop.all
    render json: @shops
  end
end
