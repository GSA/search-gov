module SearchConsumer
  module Entities
    class HeaderLinks < Grape::Entity
      expose :managed_header_links, as: "links", documentation: { type: 'array', desc: 'Expose an array of objects containing Header link information.'}
      expose :menu_button_alignment, as: "headerLinksAlignment", documentation: { type: 'string', desc: 'Alignment for Header Menu'} do |affiliate|
        affiliate.css_property_hash[:menu_button_alignment]
      end
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.load_template_schema.css.colors.header_links.to_hash
      end
    end
  end
end