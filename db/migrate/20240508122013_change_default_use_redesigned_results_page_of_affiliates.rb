class ChangeDefaultUseRedesignedResultsPageOfAffiliates < ActiveRecord::Migration[7.0]
  def change
    change_column_default :affiliates, :use_redesigned_results_page, true
   end
end
