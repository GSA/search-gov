class SearchesController < ApplicationController
  layout 'affiliate'
  
  skip_before_filter :verify_authenticity_token
  before_filter :handle_old_advanced_form, :only => [:index]
  before_filter :grab_format
  before_filter :set_affiliate_options
  before_filter :set_web_search_options, :only => [:advanced, :index]
  before_filter :set_docs_search_options, :only => :docs
  has_mobile_fu
  before_filter :adjust_mobile_mode
  SAYT_SUGGESTION_SIZE = 15
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6
  ssl_allowed :auto_complete_for_search_query, :index, :news, :docs, :advanced

  def index
    @search = WebSearch.new(@search_options)
    @search.run
    @form_path = search_path
    @page_title = @search.query
    handle_affiliate_search
    @search_vertical = :web
    respond_to do |format|
      format.any(:html, :mobile) {}
      format.json { render :json => @search }
    end
  end

  def docs
    @search = OdieSearch.new(@search_options)
    @search.run
    @form_path = docs_search_path
    @page_title = @search.query
    @search_vertical = :docs
    handle_affiliate_search
    request.format = :html
    respond_to { |format| format.html { render :action => :docs, :layout => "affiliate" } }
  end

  def news
    @search = NewsSearch.new(params.merge(:affiliate => @affiliate))
    @search.run
    @form_path = news_search_path
    @page_title = params[:query]
    handle_affiliate_search
    @search_vertical = :news
    request.format = :html
    respond_to { |format| format.html { render :action => :news, :layout => "affiliate" } }
  end

  def auto_complete_for_search_query
    query = params["mode"] == "jquery" ? params["q"] : params["query"]
    sanitized_query = query.nil? ? "" : query.squish.gsub('\\', '')
    render :inline => "" and return if sanitized_query.empty?
    @auto_complete_options = WebSearch.suggestions(nil, sanitized_query, is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE)
    if params["mode"] == "jquery"
      render :json => "#{params['callback']}(#{@auto_complete_options.map { |option| option.phrase }.to_json})"
    else
      render :inline => "<%= auto_complete_result(@auto_complete_options, 'phrase', '#{sanitized_query.gsub("'", "\\\\'")}') %>"
    end
  end

  def advanced
    @page_title = t :advanced_search
    @affiliate = @search_options[:affiliate]
    @page_title += " - #{@affiliate.display_name}"
  end

  private

  def handle_affiliate_search
    @page_title = params[:staged] ? @affiliate.build_staged_search_results_page_title(@page_title) : @affiliate.build_search_results_page_title(@page_title)
  end

  def handle_old_advanced_form
    redirect_to advanced_search_path(params.merge(:controller => "searches", :action => "advanced")) if params["form"] == "advanced-firstgov"
  end

  def grab_format
    @original_format = request.format
  end

  def set_affiliate_options
    @affiliate = params["affiliate"] ? Affiliate.find_by_name(params["affiliate"]) : nil
    @affiliate = (I18n.locale == :en ? Affiliate.find_by_name("usagov") : Affiliate.find_by_name('gobiernousa')) if @affiliate.nil?
    if @affiliate and params[:oneserp]
      @affiliate.uses_one_serp = true
      @affiliate.css_property_hash[:show_content_box_shadow] = '1'
    end
    if @affiliate && params["staged"]
      @affiliate.uses_one_serp = @affiliate.staged_uses_one_serp
      @affiliate.header_footer_sass = @affiliate.staged_header_footer_sass
      @affiliate.header = @affiliate.staged_header
      @affiliate.footer = @affiliate.staged_footer
      @affiliate.affiliate_template_id = @affiliate.staged_affiliate_template_id
      @affiliate.favicon_url = @affiliate.staged_favicon_url
      @affiliate.external_css_url = @affiliate.staged_external_css_url
      @affiliate.theme = @affiliate.staged_theme
      @affiliate.css_properties = @affiliate.staged_css_properties
      @affiliate.uses_managed_header_footer = @affiliate.staged_uses_managed_header_footer
      @affiliate.managed_header_css_properties =  @affiliate.staged_managed_header_css_properties
      @affiliate.managed_header_home_url = @affiliate.staged_managed_header_home_url
      @affiliate.managed_header_text = @affiliate.staged_managed_header_text
      @affiliate.header_image_file_name = @affiliate.staged_header_image_file_name
      @affiliate.header_image_content_type = @affiliate.staged_header_image_content_type
      @affiliate.header_image_file_size = @affiliate.staged_header_image_file_size
      @affiliate.header_image_updated_at = @affiliate.staged_header_image_updated_at
      @affiliate.managed_header_links = @affiliate.staged_managed_header_links
      @affiliate.managed_footer_links = @affiliate.staged_managed_footer_links
    end

    I18n.locale = 'es' if @affiliate.locale == 'es'
    @affiliate.use_strictui if params[:strictui]
  end

  def set_web_search_options
    params.delete("tbs")
    params.delete("channel")
    @search_options = search_options_from_params(params).merge(:affiliate => @affiliate)
  end

  def set_docs_search_options
    @search_options = {
      :affiliate => @affiliate,
      :dc => params["dc"],
      :page => [(params[:page] || "1").to_i, 1].max,
      :query => params["query"],
      :per_page => (params["per-page"] || Search::DEFAULT_PER_PAGE).to_i,
      :enable_highlighting => params["hl"].present? && params["hl"] == "false" ? false : true
    }
  end

  def adjust_mobile_mode
    request.format = :html if is_advanced_search?
    request.format = :json if @original_format == 'application/json'
  end

  def is_advanced_search?
    params[:action] == "advanced"
  end
end
