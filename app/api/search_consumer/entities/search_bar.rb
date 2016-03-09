module SearchConsumer
  module Entities
    class SearchBar < Grape::Entity
      expose :CSS, documentation: { type: 'hash', desc: 'Expose CSS values related to the Search Bar'} do |affiliate|
        affiliate.template.load_schema.css.colors.search_bar.to_hash
      end
    end
  end
end