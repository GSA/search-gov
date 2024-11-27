class AddFacetedSearchFeature < ActiveRecord::Migration[7.1]
  class Feature < ActiveRecord::Base
  end

  def self.up
    Feature.create(
      internal_name: "faceted_search",
      display_name: "Faceted Search"
    )
  end

  def self.down
    Feature.find_by_internal_name("faceted_search").destroy
  end
end
