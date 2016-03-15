module SearchConsumer
  module Entities
    class HeaderLinks < Grape::Entity      
      expose :header_links, as: "links", documentation: { type: 'array', desc: 'Expose an array of objects containing Header link information.'} do |affiliate|
        affiliate.managed_header_links
      end
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        {
          headerLinksBackgroundColor: affiliate.css_property_hash[:header_links_background_color],
          headerLinksTextColor: affiliate.css_property_hash[:header_links_text_color],
        }
      end
    end
  end
end