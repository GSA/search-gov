class ApplicationController < ActionController::Base
  include SslRequirement
  skip_before_filter :ensure_proper_protocol unless Rails.env.production?
  before_filter :set_locale
  before_filter :set_local_ip
  before_filter :show_searchbox
  helper :all
  helper_method :current_user_session, :current_user
  protect_from_forgery
  AVAILABLE_LOCALES = [:en, :es]
  VALID_FORMATS = %w{html rss json xml mobile}

  rescue_from ActionView::MissingTemplate, :with => :template_not_found

  private

  def template_not_found(error)
    if VALID_FORMATS.include?(request.format)
      raise error
    end
  end

  def set_locale
    I18n.locale = determine_locale_from_url(params[:locale]) || I18n.default_locale
  end

  def set_local_ip
    @rails_server_location_in_html_comment_for_opsview = "<!-- #{SERVER_LOCATION} -->"
  end

  def determine_locale_from_url (locale_param)
    return nil if locale_param.nil? || locale_param.match(/^\w{2}$/).nil? || !locale_exists?(locale_param)
    locale_param.to_sym
  end

  def locale_exists? (locale)
    available_locales.include?(locale.to_sym)
  end

  def available_locales
    AVAILABLE_LOCALES
  end

  def default_url_options(options={})
    {
      :locale => I18n.locale,
      :m => "false"
    }
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
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      redirect_to account_url
      return false
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

  def search_options_from_params(params)
    {
        :page => (params[:page].to_i - 1),
        :query => params["query"],
        :query_limit => params["query-limit"],
        :query_quote => params["query-quote"],
        :query_quote_limit => params["query-quote-limit"],
        :query_or => params["query-or"],
        :query_or_limit => params["query-or-limit"],
        :query_not => params["query-not"],
        :query_not_limit => params["query-not-limit"],
        :file_type => params["filetype"],
        :site_limits => params["sitelimit"],
        :site_excludes => params["siteexclude"],
        :filter => params["filter"],
        :fedstates => params["fedstates"] || nil,
        :scope_id => params["scope_id"] || nil,
        :results_per_page => params["per-page"],
        :enable_highlighting => params["hl"].present? && params["hl"] == "false" ? false : true
    }
  end
end
