class ApplicationController < ActionController::Base
  include ::SslRequirement
  skip_before_filter :ensure_proper_protocol unless Rails.env.production?
  before_filter :set_default_locale
  before_filter :set_local_ip
  before_filter :show_searchbox
  helper :all
  helper_method :current_user_session, :current_user
  protect_from_forgery
  AVAILABLE_LOCALES = [:en, :es]
  VALID_FORMATS = %w{html rss json xml mobile}

  rescue_from ActionView::MissingTemplate, :with => :template_not_found

  protected
  def set_affiliate_based_on_locale_param
    unless @affiliate
      @affiliate = params[:locale] == 'es' ? Affiliate.find_by_name('gobiernousa') : Affiliate.find_by_name('usagov')
    end
  end

  def set_locale_based_on_affiliate_locale
    I18n.locale = @affiliate.locale == 'es' ? :es : :en
  end

  private

  def template_not_found(error)
    if VALID_FORMATS.include?(request.format)
      raise error
    end
  end

  def set_locale
    I18n.locale = determine_locale_from_url(params[:locale].to_s) || I18n.default_locale
  end

  def set_default_locale
    I18n.locale = :en
  end

  def set_local_ip
    @rails_server_location_in_html_comment_for_opsview = "<!-- #{SERVER_LOCATION} -->"
  end

  def determine_locale_from_url (locale_param)
    return nil if locale_param.blank? || locale_param.match(/^\w{2}$/).nil? || !locale_exists?(locale_param)
    locale_param.to_sym
  end

  def locale_exists? (locale)
    available_locales.include?(locale.to_sym)
  end

  def available_locales
    AVAILABLE_LOCALES
  end

  def default_url_options(options={})
    request.format && request.format.to_sym == :mobile ? { :m => 'true' } : { :m => 'false' }
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      redirect_to login_url
      false
    end
  end

  def require_no_user
    if current_user
      store_location
      redirect_to account_url
      false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def establish_aws_connection
    AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
  end

  def show_searchbox
    @show_searchbox = params[:show_searchbox].present? && params[:show_searchbox] == "false" ? false : true
  end


  def search_options_from_params(affiliate, params)
    params.reject!{|k,v| params[k].instance_of? Array}
    search_params = {
      :affiliate => affiliate,
      :page => params[:page],
      :query => sanitize_query(params["query"]),
      :query_limit => params["query-limit"],
      :query_quote => sanitize_query(params["query-quote"]),
      :query_quote_limit => params["query-quote-limit"],
      :query_or => sanitize_query(params["query-or"]),
      :query_or_limit => params["query-or-limit"],
      :query_not => sanitize_query(params["query-not"]),
      :query_not_limit => params["query-not-limit"],
      :file_type => params["filetype"],
      :site_limits => params["sitelimit"],
      :site_excludes => params["siteexclude"],
      :filter => params["filter"],
      :per_page => params[:per_page],
      :enable_highlighting => params["hl"].present? && params["hl"] == "false" ? false : true,
      :dc => params["dc"],
      :channel => params["channel"],
      :tbs => params["tbs"]
    }
    search_params.merge!(:embedded => params["embedded"]) if params["embedded"].present?
    search_params
  end

  def sanitize_query(query)
    Sanitize.clean(query.to_s).gsub('&amp;', '&') if query
  end

  def set_format_for_tablet_devices
    request.format = :html if is_tablet_device?
  end

  def force_mobile_mode
    request.format = :mobile if params[:m] == "true"
    request.format = :html if params[:m] == "false" or params[:m] == "override"
  end

  def set_search_params
    @search_params = { query: @search.query, affiliate: @affiliate.name }
    if @search.is_a?(NewsSearch)
      @search_params.merge!(channel: @search.rss_feed.id) if @search.rss_feed
      @search_params.merge!(tbs: params[:tbs]) if params[:since_date].blank? and params[:until_date].blank? and params[:tbs]
      @search_params.merge!(since_date: @search.since.strftime(I18n.t(:cdr_format))) if params[:since_date].present? && @search.since
      @search_params.merge!(until_date: @search.until.strftime(I18n.t(:cdr_format))) if params[:until_date].present? && @search.until
      @search_params.merge!(sort_by: params[:sort_by]) if params[:sort_by]
      @search_params.merge!(contributor: params[:contributor]) if params[:contributor]
      @search_params.merge!(publisher: params[:publisher]) if params[:publisher]
      @search_params.merge!(subject: params[:subject]) if params[:subject]
    end
  end
end