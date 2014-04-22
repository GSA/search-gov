class AddGetsBlendedResultsToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :gets_blended_results, :boolean, null: false, default: false
  end
end
