# frozen_string_literal: true

class ElasticFeaturedCollectionData
  attr_reader :featured_collection, :language

  def initialize(featured_collection)
    @featured_collection = featured_collection
    @language = featured_collection.affiliate.indexing_locale
  end

  def to_builder
    Jbuilder.new do |json|
      json.(featured_collection, *attributes)
      json.language language
      json.set! "title.#{language}", featured_collection.title
      json.set! "link_titles.#{language}", titles
      json.keyword_values keyword_values
    end
  end

  private

  def attributes
    %i[id
       affiliate_id
       status
       publish_start_on
       publish_end_on
       match_keyword_values_only]
  end

  def titles
    featured_collection.featured_collection_links.pluck(:title)
  end

  def keyword_values
    featured_collection.featured_collection_keywords.pluck(:value)
  end
end
