module SearchConsumer
  module Entities
    class Affiliate < Grape::Entity
      expose :name
      expose :id, as: :usasearch_id, documentation: { type: 'integer', desc: 'USASEARCH unique id.'}
      expose :display_name, documentation: { type: 'string', desc: 'Unique Affiliate Site Handle.' }
      expose :website, documentation: { type: 'string', desc: 'Website URL.' }
      expose :api_access_key, documentation: { type: 'string', desc: 'API access token for the affiliate'}
    end
  end
end