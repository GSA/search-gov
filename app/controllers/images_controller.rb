class ImagesController < ApplicationController
  def index
    @search = ImageSearch.new
  end
end
