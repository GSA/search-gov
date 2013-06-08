class HomeController < ApplicationController
  before_filter :set_affiliate_based_on_locale_param, :only => [:index]
  before_filter :set_locale_based_on_affiliate_locale, :only => [:index]

  def index
    @title = "Home - "
    @search = WebSearch.new(:affiliate => @affiliate)
    respond_to { |format| format.html }
  end
end
