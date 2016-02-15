module SearchConsumer
  module Entities
    class Facets < Grape::Entity
      expose :default_search_label, as: "pageOneLabel", documentation: { type: 'string', desc: 'Name of the Page One Facet.'}
      expose :left_nav_label, documentation: { type: 'string', desc: 'Left Nav Label field is the header title for facets shown on Mobile.'}
      expose :navigations, using: SearchConsumer::Entities::FacetLinks, as: :facetLinks
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to Facets'} do |affiliate|
        affiliate.load_template_schema.css.colors.facets.to_hash
      end

      private

      def default_search_label
        object.default_search_label
      end
    end
  end
end