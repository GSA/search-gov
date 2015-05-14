class SearchesController < ApplicationController
  include MobileFriendlyController
  has_no_mobile_fu_for :advanced

  skip_before_filter :verify_authenticity_token, :set_default_locale

  before_filter :handle_old_advanced_form, :only => [:index]
  before_filter :set_affiliate, :set_locale_based_on_affiliate_locale
  before_filter :set_header_footer_fields
  before_filter :set_web_search_options, :only => [:advanced, :index]
  before_filter :set_docs_search_options, :only => :docs
  before_filter :set_news_search_options, :only => [:news, :video_news]
  before_filter :force_request_format, :only => [:advanced, :docs, :index, :news]
  before_filter :filter_params, only: :advanced
  ssl_allowed :all
  after_filter :log_search_impression, :only => [:index, :news, :docs, :video_news]

  def index
    search_klass, @search_vertical, template = pick_klass_vertical_template
    @search = search_klass.new(@search_options.merge(geoip_info: GeoipLookup.lookup(request.remote_ip)))
    @search.run
    @form_path = search_path
    @page_title = @search.query
    set_search_page_title
    set_search_params
    respond_to do |format|
      format.any(:html, :mobile) { render template }
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
    @search = WebSearch.new(@search_options)
    @affiliate = @search_options[:affiliate]
    set_search_params
    @filtered_params[:filter] = %w(0 1 2).include?(@filtered_params[:filter]) ? @filtered_params[:filter] : '1'
    @filtered_params[:filetype] = %w(doc pdf ppt txt xls).include?(@filtered_params[:filetype]) ? @filtered_params[:filetype] : nil
    respond_to { |format| format.any(:html, :mobile) {} }
  end

  private

  def pick_klass_vertical_template
    if gets_i14y_results?
      [I14ySearch, :i14y, :i14y]
    elsif gets_blended_results?
      [BlendedSearch, :blended, :blended]
    else
      [WebSearch, :web, :index]
    end
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

  def filter_params
    @filtered_params = params.permit(:affiliate,
                                     :'filetype',
                                     :filter,
                                     :m,
                                     :query,
                                     :'query-not',
                                     :'query-or',
                                     :'query-quote',
                                     :utf8)
    @filtered_params.keys.each do |field|
      @filtered_params[field] = sanitize_query @filtered_params[field]
    end
  end

  def gets_blended_results?
    @affiliate.gets_blended_results && params[:cr] != 'true'
  end

  def gets_i14y_results?
    @affiliate.gets_i14y_results && params[:cr] != 'true'
  end

  def log_search_impression
    SearchImpression.log(@search, @search_vertical, params, request)
  end
end
