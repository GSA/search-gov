module SearchConsumer
  module Entities
    class FacetLinks < Grape::Entity
      expose :name, documentation: { type: 'string', desc: 'Name of the Facet.'} do |affiliate_navigation|
        affiliate_navigation.navigable.name if affiliate_navigation.navigable
      end
      expose :navigable_facet_type, as: :type, documentation: { type: 'string', desc: 'Facet Type'}
      expose :docs_id, if: lambda{|affiliate_navigation,options| affiliate_navigation.navigable_type == "DocumentCollection"}, documentation: { type: 'string', desc: 'DocumentCollection `id` if relevant.'} do |affiliate_navigation|
        affiliate_navigation.navigable_facet_id
      end
      expose :channel_id, if: lambda{|affiliate_navigation,options| affiliate_navigation.navigable_type == "RssFeed"}, documentation: { type: 'string', desc: 'DocumentCollection `id` if relevant.'} do |affiliate_navigation|
        affiliate_navigation.navigable_facet_id
      end
      expose :is_active, as: :active, documentation: { type: 'boolean', desc: 'TRUE if facet is active.'}
    end
  end
end