module SearchConsumer
  module Entities
    class Tagline < Grape::Entity
      expose :title, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.header_tagline
      end
      expose :url, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.header_tagline_url
      end
      expose :logo_url, as: "logoUrl", documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        affiliate.header_tagline_logo.url if affiliate.header_tagline_logo_file_name.present?
      end
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Header'} do |affiliate|
        {
          headerTaglineColor: affiliate.css_property_hash[:header_tagline_color],
          headerTaglineBackgroundColor: affiliate.css_property_hash[:header_tagline_background_color]
        }
      end
    end
  end
end