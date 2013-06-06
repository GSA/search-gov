class SearchesController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :handle_old_advanced_form, :only => [:index]
  before_filter :grab_format
  before_filter :set_affiliate_options
  before_filter :set_web_search_options, :only => [:advanced, :index]
  before_filter :set_docs_search_options, :only => :docs
  before_filter :set_news_search_options, :only => [:news, :video_news]
  has_mobile_fu
  has_no_mobile_fu_for :advanced
  before_filter :set_format_for_tablet_devices
  before_filter :force_mobile_mode, :only => [:index, :docs, :news]
  before_filter :adjust_mobile_mode
  ssl_allowed :index, :news, :docs, :advanced, :videonews

  def index
    @search = WebSearch.new(@search_options.merge(geoip_info: GeoipLookup.lookup(request.remote_ip)))
    @search.run
    @form_path = search_path
    @page_title = @search.query
    set_affiliate_search_page_title
    @search_vertical = :web
    set_search_params
    respond_to do |format|
      format.any(:html, :mobile) {}
      format.json { render :json => @search }
    end
  end

  def docs
    @search = @search_options[:document_collection] ? SiteSearch.new(@search_options) : WebSearch.new(@search_options)
    @search.run
    @form_path = docs_search_path
    @page_title = @search.query
    @search_vertical = :docs
    set_affiliate_search_page_title
    set_search_params
    respond_to { |format| format.any(:html, :mobile) {} }
  end

  def news
    @search = NewsSearch.new(@search_options)
    @search.run
    @form_path = news_search_path
    set_news_search_page_title
    set_affiliate_search_page_title
    @search_vertical = :news
    set_search_params
    respond_to { |format| format.any(:html, :mobile) {} }
  end

  def video_news
    @search = VideoNewsSearch.new(@search_options)
    @search.run
    @form_path = video_news_search_path
    set_news_search_page_title
    set_affiliate_search_page_title
    @search_vertical = :news
    request.format = :html
    set_search_params
    respond_to { |format| format.html { render action: :news } }
  end

  def advanced
    @page_title = t :advanced_search
    @affiliate = @search_options[:affiliate]
    @page_title += " - #{@affiliate.display_name}"
  end

  private

  def set_affiliate_search_page_title
    @page_title = params[:staged] ? @affiliate.build_staged_search_results_page_title(@page_title) : @affiliate.build_search_results_page_title(@page_title)
  end

  def set_news_search_page_title
    if params[:query].present?
      @page_title = params[:query]
    elsif @search.rss_feed and @search.total > 0
      @page_title = @search.rss_feed.name
    end
  end

  def handle_old_advanced_form
    redirect_to advanced_search_path(params.merge(:controller => "searches", :action => "advanced")) if params["form"] == "advanced-firstgov"
  end

  def grab_format
    @original_format = request.format
  end

  def set_affiliate_options
    @affiliate = Affiliate.find_by_name(params[:affiliate].to_s) unless params[:affiliate].blank?
    set_affiliate_based_on_locale_param
    set_locale_based_on_affiliate_locale
    if @affiliate && params["staged"]
      @affiliate.nested_header_footer_css = @affiliate.staged_nested_header_footer_css
      @affiliate.header = @affiliate.staged_header
      @affiliate.footer = @affiliate.staged_footer
      @affiliate.favicon_url = @affiliate.staged_favicon_url
      @affiliate.external_css_url = @affiliate.staged_external_css_url
      @affiliate.theme = @affiliate.staged_theme
      @affiliate.css_properties = @affiliate.staged_css_properties
      @affiliate.uses_managed_header_footer = @affiliate.staged_uses_managed_header_footer
      @affiliate.managed_header_css_properties = @affiliate.staged_managed_header_css_properties
      @affiliate.managed_header_home_url = @affiliate.staged_managed_header_home_url
      @affiliate.managed_header_text = @affiliate.staged_managed_header_text
      @affiliate.header_image_file_name = @affiliate.staged_header_image_file_name
      @affiliate.header_image_content_type = @affiliate.staged_header_image_content_type
      @affiliate.header_image_file_size = @affiliate.staged_header_image_file_size
      @affiliate.header_image_updated_at = @affiliate.staged_header_image_updated_at
      @affiliate.managed_header_links = @affiliate.staged_managed_header_links
      @affiliate.managed_footer_links = @affiliate.staged_managed_footer_links
      @affiliate.page_background_image_file_name = @affiliate.staged_page_background_image_file_name
      @affiliate.page_background_image_content_type = @affiliate.staged_page_background_image_content_type
      @affiliate.page_background_image_file_size = @affiliate.staged_page_background_image_file_size
      @affiliate.page_background_image_updated_at = @affiliate.staged_page_background_image_updated_at
      @affiliate.mobile_homepage_url = @affiliate.staged_mobile_homepage_url
      @affiliate.mobile_logo_file_name = @affiliate.staged_mobile_logo_file_name
      @affiliate.mobile_logo_content_type = @affiliate.staged_mobile_logo_content_type
      @affiliate.mobile_logo_file_size = @affiliate.staged_mobile_logo_file_size
      @affiliate.mobile_logo_updated_at = @affiliate.staged_mobile_logo_updated_at
    end

    @affiliate.use_strictui if params[:strictui]
  end

  def set_web_search_options
    %w{tbs channel}.each { |param| params.delete(param) }
    @search_options = search_options_from_params(@affiliate, params)
  end

  def set_docs_search_options
    @search_options = search_options_from_params(@affiliate, params)
    document_collection = @affiliate.document_collections.find_by_id(@search_options[:dc].to_i) rescue nil
    @search_options.merge!(document_collection: document_collection)
  end

  def set_news_search_options
    @search_options = search_options_from_params(@affiliate, params)
    @search_options.merge!(contributor: params[:contributor],
                           subject: params[:subject],
                           publisher: params[:publisher],
                           sort_by: params[:sort_by],
                           since_date: params[:since_date],
                           until_date: params[:until_date])
  end

  def adjust_mobile_mode
    request.format = :json if @original_format == 'application/json'
  end
end
