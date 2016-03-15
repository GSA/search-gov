module SearchConsumer
  module Entities
    class AffiliateFacets < Grape::Entity
      expose :name, documentation: { type: 'string', desc: 'Name of the Facet.'} do |instance|
        instance.navigable.name if instance.navigable
      end
      expose :navigable_facet_type, as: :type, documentation: { type: 'string', desc: 'Facet Type'}

      expose :docs_id, if: lambda{|instance,options| instance.navigable_type == "DocumentCollection"}, documentation: { type: 'string', desc: 'DocumentCollection `id` if relevant.'} do |instance|
        instance.navigable_facet_id
      end
      expose :channel_id, if: lambda{|instance,options| instance.navigable_type == "RssFeed"}, documentation: { type: 'string', desc: 'DocumentCollection `id` if relevant.'} do |instance|
        instance.navigable_facet_id
      end
      expose :is_active, as: :active, documentation: { type: 'boolean', desc: 'TRUE if facet is active.'}
    end
  end
end