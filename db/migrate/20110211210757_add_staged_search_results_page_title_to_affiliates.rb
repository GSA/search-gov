class AddStagedSearchResultsPageTitleToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :staged_search_results_page_title, :string, :null => false
    update("update affiliates set staged_search_results_page_title = '{Query} - {SiteName} Search Results'")
  end

  def self.down
    remove_column :affiliates, :staged_search_results_page_title
  end
end
