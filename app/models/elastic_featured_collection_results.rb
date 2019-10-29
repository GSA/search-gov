# frozen_string_literal: true

class ElasticFeaturedCollectionResults < ElasticResults

  def highlight_instance(highlight, instance)
    instance.title = highlight['title'].first if highlight['title']
    highlight_link_titles(highlight['link_titles'], instance) if highlight['link_titles']
    instance
  end

  def highlight_link_titles(highlighted_link_titles, instance)
    highlighted_link_titles.each do |link_title|
      fcl = instance.featured_collection_links.detect { |fcl| fcl.title == Sanitize.clean(link_title) }
      fcl.title = link_title if fcl
    end
  end
end