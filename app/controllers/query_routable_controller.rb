require 'active_support/concern'

module QueryRoutableController
  QueryRoutedSearch = Struct.new(:modules)
  extend ActiveSupport::Concern

  included do
    before_filter :handle_query_routing, only: :index
  end

  private

  def handle_query_routing
    return unless @search_options[:affiliate].present? and @search_options[:query].present?
    routed_query = @search_options[:affiliate].routed_queries
                     .joins(:routed_query_keywords)
                     .where(routed_query_keywords:{keyword: @search_options[:query]})
                     .first
    if routed_query.present? and !matching_urls_for(routed_query.url).include?(request.referrer)
      log_routed_query_impression
      redirect_to routed_query.url
    end
  end

  def log_routed_query_impression
    mock_search = QueryRoutedSearch.new(%w(QRTD))
    relevant_params = { affiliate: @search_options[:affiliate].name, query: @search_options[:query] }
    SearchImpression.log(mock_search, :web, relevant_params, request)
  end

  def matching_urls_for(url)
    u = URI.parse(url)
    u.scheme = u.scheme == 'http' ? 'https' : 'http'
    [ url, u.to_s ]
  end

end
