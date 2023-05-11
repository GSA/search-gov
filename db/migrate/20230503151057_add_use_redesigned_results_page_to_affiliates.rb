class AddUseRedesignedResultsPageToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :use_redesigned_results_page, :boolean, :default => false
  end
end
