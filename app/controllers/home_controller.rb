class HomeController < ApplicationController
  has_mobile_fu
  before_filter :force_mobile_mode
  before_filter :set_format_for_tablet_devices
  before_filter :set_affiliate_based_on_locale_param, :only => [:index]
  before_filter :set_locale_based_on_affiliate_locale, :only => [:index]

  def index
    @title = "Home - "
    @search = WebSearch.new(:affiliate => @affiliate)
    respond_to do |format|
      format.any(:html, :mobile)
    end
  end

end
