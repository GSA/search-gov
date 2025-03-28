class AddGetsResultsFromAllDomainsToAffiliates < ActiveRecord::Migration[7.1]
  def change
    add_column :affiliates, :gets_results_from_all_domains, :boolean, default: false, null: false
  end
end
