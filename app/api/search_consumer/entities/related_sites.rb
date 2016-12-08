module SearchConsumer
  module Entities
    class RelatedSites < Grape::Entity
      expose :id, documentation: { type: 'integer' }
      expose :connected_affiliate_id, documentation: { type: 'integer' }
      expose :label, documentation: { type: 'string', desc: 'Label'}
      expose :position, documentation: { type: 'integer' }
    end
  end
end
