class AddMrssNameToRssFeedUrl < ActiveRecord::Migration
  def change
    add_column :rss_feed_urls, :oasis_mrss_name, :string
  end
end
