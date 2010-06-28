class ApplicationController < ActionController::Base
  include SslRequirement
  skip_before_filter :ensure_proper_protocol unless Rails.env.production?
  before_filter :set_locale
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  protect_from_forgery
  AVAILABLE_LOCALES = [:en, :es]

  private

  def set_locale
    I18n.locale = determine_locale_from_param(params[:locale]) || I18n.default_locale
  end

  def determine_locale_from_param (locale_param)
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
      redirect_to new_user_session_url
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
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def establish_aws_connection
    AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
  end

end
