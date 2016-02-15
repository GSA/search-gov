module SearchConsumer
  module Entities
    class Footer < Grape::Entity
      expose :footer_links, as: "footerLinks", documentation: { type: 'array', desc: 'Expose an array of objects containing Footer link information.'} do |affiliate|
        affiliate.managed_footer_links
      end
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        {
          footerBackgroundColor: affiliate.css_property_hash[:footer_background_color],
          footerLinksTextColor: affiliate.css_property_hash[:footer_links_text_color]
        }
      end
    end
  end
end