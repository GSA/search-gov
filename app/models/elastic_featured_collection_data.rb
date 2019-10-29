class ElasticFeaturedCollectionData
  def initialize(featured_collection)
    @featured_collection = featured_collection
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@featured_collection, :id, :affiliate_id, :title, :status, :publish_start_on, :publish_end_on, :match_keyword_values_only)
      json.language "#{@featured_collection.affiliate.indexing_locale}_analyzer"
      json.link_titles @featured_collection.featured_collection_links.collect(&:title)
      json.keyword_values @featured_collection.featured_collection_keywords.collect(&:value)
    end
  end

end