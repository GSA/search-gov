class AddSearchResultsPageTitleToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :search_results_page_title, :string, :null => false
    update("update affiliates set search_results_page_title = '{Query} - {SiteName} Search Results'")
  end

  def self.down
    remove_column :affiliates, :search_results_page_title
  end
end
