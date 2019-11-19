# frozen_string_literal: true

require 'active_support/concern'

module QueryRoutableController
  extend ActiveSupport::Concern

  included do
    before_action :handle_query_routing, only: :index
  end

  def index; end

  private

  def handle_query_routing
    return unless @search_options[:affiliate].present? && @search_options[:query].present?

    if routed_query.present? &&
       !matching_urls_for(routed_query.url).include?(request.referer)
      RoutedQueryImpressionLogger.log(@search_options[:affiliate],
                                      @search_options[:query], request)
      redirect_to(routed_query.url)
    end
  end

  def matching_urls_for(url)
    u = URI.parse(url)
    u.scheme = u.scheme == 'http' ? 'https' : 'http'
    [url, u.to_s]
  end

  def routed_query
    @routed_query ||= @search_options[:affiliate].routed_queries.
                        joins(:routed_query_keywords).
                        where(
                          routed_query_keywords: { keyword: @search_options[:query] }
                        ).first
  end
end
