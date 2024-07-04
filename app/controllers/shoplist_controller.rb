class ShoplistController < ApplicationController
  def index
    @shops = RamenShop.all
  end

  def show
    @shop = RamenShop.find_by(id: params[:id])
    redirect_to root_path, alert: "店舗が見つかりません" if @shop.nil?
  end
end
