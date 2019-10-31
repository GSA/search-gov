class SearchesController < ApplicationController
  include MobileFriendlyController
  has_no_mobile_fu_for :advanced

  skip_before_action :verify_authenticity_token, :set_default_locale

  before_action :handle_old_advanced_form, :only => [:index]
  before_action :set_affiliate, :set_locale_based_on_affiliate_locale
  #eventually all the searches should be redirected, but currently we're doing it as-needed
  #to ensure that the correct params are being passed, etc.
  before_action :redirect_to_search_consumer, only: [:index, :news, :docs]
  before_action :set_header_footer_fields
  before_action :set_web_search_options, :only => [:advanced, :index]
  before_action :set_docs_search_options, :only => :docs
  before_action :set_news_search_options, :only => [:news, :video_news]
  before_action :force_request_format, :only => [:advanced, :docs, :index, :news]
  after_action :log_search_impression, :only => [:index, :news, :docs, :video_news]
  include QueryRoutableController

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
    search_klass = docs_search_klass
    @search = search_klass.new(@search_options)
    @search.run
    @form_path = docs_search_path
    @page_title = @search.query
    @search_vertical = :docs
    set_search_page_title
    set_search_params
    template = search_klass == I14ySearch ? :i14y : :docs
    respond_to { |format| format.any(:html, :mobile) { render template } }
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
    permitted_params[:filter] = %w(0 1 2).include?(permitted_params[:filter]) ? permitted_params[:filter] : '1'
    permitted_params[:filetype] = %w(doc pdf ppt txt xls).include?(permitted_params[:filetype]) ? permitted_params[:filetype] : nil
    respond_to { |format| format.any(:html, :mobile) {} }
  end

  private

  def pick_klass_vertical_template
    if get_commercial_results?
      [WebSearch, :web, :index]
    elsif gets_i14y_results?
      [I14ySearch, :i14y, :i14y]
    elsif @affiliate.gets_blended_results
      [BlendedSearch, :blended, :blended]
    else
      [WebSearch, :web, :index]
    end
  end

  def set_news_search_page_title
    if permitted_params[:query].present?
      @page_title = permitted_params[:query]
    elsif @search.rss_feed and @search.total > 0
      @page_title = @search.rss_feed.name
    end
  end

  def handle_old_advanced_form
    if permitted_params['form'] == 'advanced-firstgov'
      redirect_to advanced_search_path permitted_params
    end
  end

  def set_web_search_options
    @search_options = search_options_from_params :filter,
                                                 :since_date,
                                                 :sort_by,
                                                 :tbs,
                                                 :until_date
  end

  def set_docs_search_options
    @search_options = search_options_from_params :dc,
                                                 :since_date,
                                                 :sort_by,
                                                 :tbs,
                                                 :until_date
    document_collection = @affiliate.document_collections.find_by_id(@search_options[:dc])
    @search_options.merge!(document_collection: document_collection)
  end

  def set_news_search_options
    @search_options = search_options_from_params :channel,
                                                 :contributor,
                                                 :publisher,
                                                 :since_date,
                                                 :sort_by,
                                                 :subject,
                                                 :tbs,
                                                 :until_date
  end

  def get_commercial_results?
    permitted_params[:cr] == 'true'
  end

  def gets_i14y_results?
    @affiliate.search_engine == 'SearchGov' ||
      @affiliate.gets_i14y_results ||
      @search_options[:document_collection]&.too_deep_for_bing?
  end

  def log_search_impression
    if !@affiliate.search_consumer_search_enabled?
      SearchImpression.log(@search, @search_vertical, permitted_params, request)
    end
  end

  def redirect_to_search_consumer
    if @affiliate.search_consumer_search_enabled?
      redirect_to self.send(search_consumer_urls[action_name], permitted_params) and return
    end
  end

  def search_consumer_urls
    { 'index' => :search_consumer_search_url,
      'news' => :search_consumer_news_search_url,
      'docs' => :search_consumer_docs_search_url,
    }
  end

  def docs_search_klass
    return I14ySearch if gets_i14y_results?
    @search_options[:document_collection] ? SiteSearch : WebSearch
  end
end
