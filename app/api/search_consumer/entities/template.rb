module SearchConsumer
  module Entities
    class Template < Grape::Entity
      expose :template_type, as: "templateType", documentation: { type: 'string', desc: 'Template type used by Search Consumer'} do |affiliate|
        affiliate.template.class.name
      end
      expose :favicon_url, as: "faviconUrl", documentation: { type: 'string', desc: 'Favicon url for the Affiliate'}
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.template.load_schema.css.colors.template.to_hash
      end
    end
  end
end