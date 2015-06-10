require 'active_support/concern'

module QueryRoutableController
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
    redirect_to routed_query.url if routed_query.present? and routed_query.url != request.referrer
  end

end
