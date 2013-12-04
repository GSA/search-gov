class ElasticFeaturedCollectionResults < ElasticResults

  def extract_results(hits)
    ids = hits.collect { |hit| hit['_id'] }
    instances = FeaturedCollection.where(id: ids).includes([:featured_collection_links, :featured_collection_keywords])
    instance_hash = Hash[instances.map { |instance| [instance.id, instance] }]
    hits.map { |hit| highlight_instance(hit['highlight'], instance_hash[hit['_id'].to_i]) }.compact
  end

  private

  def highlight_instance(highlight, instance)
    if highlight.present? and instance.present?
      instance.title = highlight['title'].first if highlight['title']
      highlight_link_titles(highlight['link_titles'], instance) if highlight['link_titles']
    end
    instance
  end

  def highlight_link_titles(highlighted_link_titles, instance)
    highlighted_link_titles.each do |link_title|
      fcl = instance.featured_collection_links.detect { |fcl| fcl.title == Sanitize.clean(link_title) }
      fcl.title = link_title if fcl
    end
  end
end