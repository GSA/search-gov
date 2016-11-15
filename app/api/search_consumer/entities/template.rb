module SearchConsumer
  module Entities
    class Template < Grape::Entity
      expose :template_type, as: "templateType", documentation: { type: 'string', desc: 'Template type used by Search Consumer'} do |affiliate|
        "Template::#{affiliate.template.klass}"
      end
      expose :favicon_url, as: "faviconUrl", documentation: { type: 'string', desc: 'Favicon url for the Affiliate'}

      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        (affiliate.load_template_schema.css.colors.template.to_hash).merge(affiliate.load_template_schema.css.font.to_hash)
      end
    end
  end
end
