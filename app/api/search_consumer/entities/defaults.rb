module SearchConsumer
  module Entities
    class Defaults < Grape::Entity
      expose :api_access_key, as: "apiAccessKey", documentation: { type: 'string', desc: 'API access token for the affiliate'}
      expose :display_name, as: "displayName", documentation: { type: 'string', desc: 'Unique Affiliate Site Handle.' }
      expose :id, as: "usasearchId", documentation: { type: 'integer', desc: 'USASEARCH unique id.'}
      expose :locale, documentation: { type: 'string', desc: 'Default locale for the affiliate.'}
      expose :name
      expose :search_engine, as: "searchEngine", documentation: { type: 'string', desc: 'Search engine to be used [Bing, Google, Azure]'}
      expose :search_type, as: "searchType", documentation: { type: 'string', desc: 'Default Search Type, [i14y, Blended, Web].'} do |affiliate|
        if affiliate.gets_i14y_results?
          'i14y'
        elsif affiliate.gets_blended_results?
          'blended'
        else
          'web'
        end
      end
      expose :template_type, as: "templateType", documentation: { type: 'string', desc: 'Template type used by Search Consumer'}
      expose :website, documentation: { type: 'string', desc: 'Website URL.' }
    end
  end
end