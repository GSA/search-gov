class ImagesController < ApplicationController
  def index
    @search = ImageSearch.new
    @affiliate = I18n.locale == :es ? Affiliate.find_by_name('gobiernousa') : Affiliate.find_by_name('usagov')
  end
end
