class UsaController < ApplicationController
  has_mobile_fu
  before_filter :force_mobile_mode
  before_filter :override_locale_based_on_url

  def show
    @search = WebSearch.new
    @site_page = SitePage.find_by_url_slug(params["url_slug"])
    redirect_to home_page_path and return if @site_page.nil?
    @title = @site_page.title
  end

  private

  def override_locale_based_on_url
    I18n.locale = request.url.include?("/gobiernousa") ? :es : I18n.default_locale
  end

  def force_mobile_mode
    request.format = 'mobile'
  end
end
