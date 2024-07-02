require 'faker'

class PagesController < ApplicationController
  def index
    @shops = RamenShop.all
  end
end
