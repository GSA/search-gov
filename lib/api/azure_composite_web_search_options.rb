class Api::AzureCompositeWebSearchOptions < Api::CommercialSearchOptions
  SOURCES = 'web+spell'.freeze

  def attributes
    super.merge({
      sources: SOURCES,
    })
  end
end
