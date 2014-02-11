class AddLanguageToRssFeedUrl < ActiveRecord::Migration
  def change
    add_column :rss_feed_urls, :language, :string
  end
end
