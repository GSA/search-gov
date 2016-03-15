module SearchConsumer
  module Entities
    class ResultsContainer < Grape::Entity
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Page Wide Defaults'} do |affiliate|
        {
          titleLinkColor: affiliate.css_property_hash[:title_link_color],
          visitedTitleLinkColor: affiliate.css_property_hash[:visited_title_link_color],
          urlLinkColor: affiliate.css_property_hash[:url_link_color],
          descriptionTextColor: affiliate.css_property_hash[:description_text_color]
        }
      end
    end
  end
end