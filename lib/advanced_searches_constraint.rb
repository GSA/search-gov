# frozen_string_literal: true

class AdvancedSearchesConstraint
  def matches?(request)
    affiliate = request.query_parameters['affiliate']

    Affiliate.exists?(name: affiliate, search_engine: 'SearchGov')
  end
end
