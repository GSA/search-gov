# frozen_string_literal: true

class ElasticFeaturedCollectionQuery < ElasticBestBetQuery
  def initialize(options)
    super(options)
    @text_fields = %w[title link_titles]
  end
end
