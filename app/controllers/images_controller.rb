class ImagesController < ApplicationController
  def index
    @affiliate = I18n.locale == :es ? Affiliate.find_by_name('gobiernousa') : Affiliate.find_by_name('usagov')
    @search = ImageSearch.new(:affiliate => @affiliate)
  end
end
