module SearchConsumer
  module Entities
    class Header < Grape::Entity
      expose :logo_image_url, as: "logoImageUrl", documentation: { type: 'string', desc: 'Header Image Logo url.'} do |affiliate|
        affiliate.mobile_logo.url if affiliate.mobile_logo_file_name.present?
      end
      expose :logo_alignment, as: "logoAlignment", documentation: { type: 'string', desc: 'Logo Alignment within header' } do |affiliate|
        affiliate.css_property_hash[:logo_alignment] if affiliate.css_property_hash
      end
      expose :logo_alt_text, as: "logoAltText", documentation: { type: 'string', desc: 'Alt text for the Header Logo' }
      expose :menu_button_alignment, as: "headerLinksAlignment", documentation: { type: 'string', desc: 'Alignment for Header Menu'} do |affiliate|
        affiliate.css_property_hash[:menu_button_alignment]
      end
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.template.load_schema.css.colors.header.to_hash
      end
    end
  end
end