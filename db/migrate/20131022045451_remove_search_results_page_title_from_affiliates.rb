class RemoveSearchResultsPageTitleFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :search_results_page_title
    remove_column :affiliates, :staged_search_results_page_title
  end

  def down
    add_column :affiliates, :staged_search_results_page_title, :string, null: false
    add_column :affiliates, :search_results_page_title, :string, null: false
  end
end
