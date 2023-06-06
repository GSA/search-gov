# frozen_string_literal: true

class AdvancedSearchesConstraint
  def matches?(request)
    'SearchGov'.include?(requested_engine(request))
  end

  def requested_engine(request)
    affiliate = request.query_parameters['affiliate']
    Affiliate.find_by(name: affiliate).search_engine
  end
end
