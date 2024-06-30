class ShoplistController < ApplicationController
  def index
    @ramen_shops = RamenShop.all
  end
end
