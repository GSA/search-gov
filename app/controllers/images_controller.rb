class ImagesController < ApplicationController
  before_filter :set_affiliate_based_on_locale_param
  before_filter :set_locale_based_on_affiliate_locale

  def index
    @search = ImageSearch.new(:affiliate => @affiliate)
  end
end
