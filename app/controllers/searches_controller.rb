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
    search_klass, @search_vertical, template = gets_blended_results? ? [BlendedSearch, :blended, :blended] : [WebSearch, :web, :index]
    @search = search_klass.new(@search_options.merge(geoip_info: GeoipLookup.lookup(request.remote_ip)))
    @search.run
    @form_path = search_path
    @page_title = @search.query
    set_search_page_title
    set_search_params
    respond_to do |format|
      format.any(:html, :mobile) {render template}
      format.json { render :json => @search }
    end
  end

  def docs
    @search = @search_options[:document_collection] ? SiteSearch.new(@search_options) : WebSearch.new(@search_options)
    @search.run
    @form_path = docs_search_path
    @page_title = @search.query
    @search_vertical = :docs
    set_search_page_title
    set_search_params
    respond_to { |format| format.any(:html, :mobile) {} }
  end

  def news
    @search = NewsSearch.new(@search_options)
    @search.run
    @form_path = news_search_path
    set_news_search_page_title
    set_search_page_title
    @search_vertical = :news
    set_search_params
    respond_to { |format| format.any(:html, :mobile) {} }
  end

  def video_news
    @search = VideoNewsSearch.new(@search_options)
    @search.run
    @form_path = video_news_search_path
    set_news_search_page_title
    set_search_page_title
    @search_vertical = :news
    request.format = :html
    set_search_params
    respond_to { |format| format.html { render action: :news } }
  end

  def advanced
    @page_title = "#{t(:advanced_search)} - #{@affiliate.display_name}"
    @affiliate = @search_options[:affiliate]
    request.format = :html
    respond_to { |format| format.html {} }
  end

  private

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
    if @affiliate && params['staged']
      @affiliate.nested_header_footer_css = @affiliate.staged_nested_header_footer_css
      @affiliate.header = @affiliate.staged_header
      @affiliate.footer = @affiliate.staged_footer
      @affiliate.uses_managed_header_footer = @affiliate.staged_uses_managed_header_footer
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

  def default_url_options(options={})
    request.format && request.format.to_sym == :mobile ? { :m => 'true' } : { :m => 'false' }
  end

  def gets_blended_results?
    @affiliate.gets_blended_results && params[:cr] != 'true'
  end

end
