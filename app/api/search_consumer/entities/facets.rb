module SearchConsumer
  module Entities
    class Facets < Grape::Entity
      expose :default_search_label, as: "pageOneLabel", documentation: { type: 'string', desc: 'Name of the Page One Facet.'}
      expose :navigations, using: SearchConsumer::Entities::FacetLinks, as: :facetLinks
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to Facets'} do |affiliate|
        {
          activeFacetLinkColor: affiliate.css_property_hash[:left_tab_text_color],
          facetsBackgroundColor: affiliate.css_property_hash[:navigation_background_color],
          facetLinkColor: affiliate.css_property_hash[:navigation_link_color]
        }
      end

      private 

      def default_search_label
        "Hello + #{object.default_search_label}"
      end

    end
  end
end