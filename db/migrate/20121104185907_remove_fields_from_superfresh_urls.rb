class RemoveFieldsFromSuperfreshUrls < ActiveRecord::Migration
  def change
    remove_column :superfresh_urls, :updated_at
    remove_column :superfresh_urls, :crawled_at
  end
end
