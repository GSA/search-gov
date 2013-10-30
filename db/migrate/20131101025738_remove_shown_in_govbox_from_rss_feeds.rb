class RemoveShownInGovboxFromRssFeeds < ActiveRecord::Migration
  def up
    remove_column :rss_feeds, :shown_in_govbox
  end

  def down
    add_column :rss_feeds, :shown_in_govbox, :boolean, default: false, null: false
  end
end
