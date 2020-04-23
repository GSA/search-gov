# frozen_string_literal: true

class ModuleBreakdownQuery
  include AnalyticsDSL

  def initialize(affiliate_name = nil)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      type_terms_agg(json, 'modules', 100)
    end
  end

  def booleans(json)
    must_affiliate(json, @affiliate_name) if @affiliate_name.present?
    must_type(json, %w[search click])
    must_not_spider(json)
  end
end
