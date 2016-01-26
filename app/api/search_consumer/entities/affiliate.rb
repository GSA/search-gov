module SearchConsumer
  module Entities
    class Affiliate < Grape::Entity
      expose :name
      expose :id, as: :usasearch_id, documentation: { type: 'integer', desc: 'USASEARCH unique id.'}
      expose :display_name, documentation: { type: 'string', desc: 'Unique Affiliate Site Handle.' }
      expose :website, documentation: { type: 'string', desc: 'Website URL.' }
      expose :api_access_key, documentation: { type: 'string', desc: 'API access token for the affiliate'}
      expose :default_search_label, as: :page_one_label, documentation: { type: 'string', desc: 'Name of the Page One Facet.'}
      expose :locale, documentation: { type: 'string', desc: 'Default locale for the affiliate.'}
      expose :search_type, documentation: { type: 'string', desc: 'Default Search Type, [i14y, Blended, Web].'} do |instance|
        if instance.gets_i14y_results?
          'i14y'
        elsif instance.gets_blended_results?
          'blended'
        else
          'web'
        end
      end
    end
  end
end