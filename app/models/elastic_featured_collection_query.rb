class ElasticFeaturedCollectionQuery < ElasticBestBetQuery
  def initialize(options)
    super(options)
    self.highlighted_fields = %w(title link_titles)
  end
end