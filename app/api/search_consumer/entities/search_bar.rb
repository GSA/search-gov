module SearchConsumer
  module Entities
    class SearchBar < Grape::Entity
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Search Bar'} do |affiliate|
        {
          searchButtonBackgroundColor: affiliate.css_property_hash[:search_button_background_color]
        }
      end
    end
  end
end