module SearchConsumer
  module Entities
    class Template < Grape::Entity
      expose :template_type, as: "templateType", documentation: { type: 'string', desc: 'Template type used by Search Consumer'}
      expose :favicon_url, as: "faviconUrl", documentation: { type: 'string', desc: 'Favicon url for the Affiliate'}
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        {
          fontFamily: affiliate.css_property_hash[:font_family],
          pageBackground: affiliate.css_property_hash[:page_background_color]
        }
      end
    end
  end
end