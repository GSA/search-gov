# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_default_locale
  after_action :set_response_headers
  helper :all
  helper_method :current_user_session, :current_user, :permitted_params
  protect_from_forgery with: :exception
  SERP_RESULTS_PER_PAGE = 20
  PAGE_NOT_FOUND = 'https://www.usa.gov/search-error'

  ADVANCED_PARAM_KEYS = %i(filetype filter query-not query-or query-quote).freeze
  DUBLIN_CORE_PARAM_KEYS = %i(contributor publisher subject).freeze
  FILTER_PARAM_KEYS = %i(since_date sort_by tbs until_date).freeze

  PERMITTED_PARAM_KEYS = %i(
    affiliate
    autodiscovery_url
    channel
    commit
    cr
    dc
    email_to_verify
    form
    hl
    m
    page
    query
    staged
    strictui
    siteexclude
    sitelimit
    utf8
  ).concat(ADVANCED_PARAM_KEYS).
    concat(DUBLIN_CORE_PARAM_KEYS).
    concat(FILTER_PARAM_KEYS).freeze

  def handle_unverified_request
    raise ActionController::InvalidAuthenticityToken
  end

  protected

  def set_affiliate
    @affiliate = Affiliate.active.find_by_name(permitted_params[:affiliate])
    redirect_unless_affiliate
  end

  def redirect_unless_affiliate
    unless @affiliate
      redirect_to(PAGE_NOT_FOUND) and return
    end
  end

  def set_header_footer_fields
    if @affiliate && permitted_params['staged']
      @affiliate.nested_header_footer_css = @affiliate.staged_nested_header_footer_css
      @affiliate.header = @affiliate.staged_header
      @affiliate.footer = @affiliate.staged_footer
      @affiliate.uses_managed_header_footer = @affiliate.staged_uses_managed_header_footer
    end

    @affiliate.use_strictui if permitted_params[:strictui]
  end

  def set_locale_based_on_affiliate_locale
    I18n.locale = @affiliate.locale.to_sym
  end

  private

  def set_default_locale
    I18n.locale = :en
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

  def store_location
    session[:return_to] = request.fullpath
  end

  def permitted_params
    @permitted_params ||= params.permit(*PERMITTED_PARAM_KEYS).to_h
  end

  def search_options_from_params(*param_keys)
    h = permitted_params.slice(*param_keys)
    h.merge! affiliate: @affiliate,
             file_type: permitted_params[:filetype],
             page: permitted_params[:page],
             per_page: SERP_RESULTS_PER_PAGE,
             site_limits: permitted_params[:sitelimit],
             site_excludes: permitted_params[:siteexclude]
    h.merge! query_search_options
    h.merge! highlighting_option
    h.symbolize_keys
  end

  def query_search_options
    query_search_params = permitted_params.slice(:query,
                                                 :'query-not',
                                                 :'query-or',
                                                 :'query-quote')
    query_search_params.inject({}) do |hash, kv|
      hash[kv.first.to_s.underscore.to_sym] = sanitize_query kv.last
      hash
    end
  end

  def sanitize_query(query)
    QuerySanitizer.sanitize(query)
  end

  def highlighting_option
    { enable_highlighting: permitted_params[:hl] == 'false' ? false : true }
  end

  def force_request_format
    return if request.format && request.format.json?

    if @affiliate.force_mobile_format? || permitted_params[:m] == 'true'
      request.format = :mobile
    elsif permitted_params[:m] == 'false' or permitted_params[:m] == 'override'
      request.format = :html
    end
  end

  def set_search_params
    @search_params = ActiveSupport::HashWithIndifferentAccess.new(query: @search.query, affiliate: @affiliate.name)
    @search_params.merge!(sitelimit: permitted_params[:sitelimit]) if permitted_params[:sitelimit].present?
    @search_params.merge!(dc: permitted_params[:dc]) if permitted_params[:dc].present?
    if @search.is_a? FilterableSearch
      @search_params.merge!(channel: @search.rss_feed.id) if @search.is_a?(NewsSearch) && @search.rss_feed
      @search_params.merge!(tbs: @search.tbs) if @search.tbs
      @search_params.merge!(since_date: @search.since.strftime(I18n.t(:cdr_format))) if permitted_params[:since_date].present? && @search.since
      @search_params.merge!(until_date: @search.until.strftime(I18n.t(:cdr_format))) if permitted_params[:until_date].present? && @search.until
      @search_params.merge!(permitted_params.slice(:contributor, :publisher, :sort_by, :subject))
    end
  end

  def set_search_page_title
    query_string = @page_title.blank? ? '' : @page_title
    @page_title = I18n.t(:default_serp_title,
                         query: query_string,
                         site_name: @affiliate.display_name)
  end

  def set_response_headers
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
  end

  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
  end
end
