class HomeController < ApplicationController
  has_mobile_fu
  def index
    @search = Search.new
  end
end
