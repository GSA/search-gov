class Api::AzureCompositeImageSearchOptions < Api::CommercialSearchOptions
  IMAGE_FILTERS = 'Aspect:Square'.freeze
  SOURCES = 'image+spell'.freeze

  def attributes
    super.merge({
      sources: SOURCES,
      image_filters: IMAGE_FILTERS,
    })
  end
end
