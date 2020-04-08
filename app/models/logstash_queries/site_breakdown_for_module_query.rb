# frozen_string_literal: true

class SiteBreakdownForModuleQuery
  include AnalyticsDSL

  attr_reader :module_tag

  def initialize(module_tag)
    @module_tag = module_tag
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      type_terms_agg(json, 'params.affiliate', 10_000)
    end
  end

  def booleans(json)
    must_module(json, module_tag)
    must_type(json, %w[search click])
    must_not_spider(json)
  end
end
