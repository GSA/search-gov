class AddGetsCommercialResultsOnBlendedSearchToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :gets_commercial_results_on_blended_search, :boolean, null: false, default: true
  end
end
