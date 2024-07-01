class ShoplistController < ApplicationController
  def index
    @texts = session[:texts].map { |text| OpenStruct.new(text) }
  end

  def show
    texts = session[:texts].map { |text| OpenStruct.new(text) }
    @shop = texts.find { |text| text.id == params[:id] }
    if @shop.nil?
      redirect_to root_path, alert: "店舗が見つかりません"
    end
  end
end
