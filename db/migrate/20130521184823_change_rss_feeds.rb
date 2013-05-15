class ChangeRssFeeds < ActiveRecord::Migration
  def up
    rename_column :rss_feeds, :affiliate_id, :owner_id
    add_column :rss_feeds, :owner_type, :string, null: false
    add_index :rss_feeds, [:owner_type, :owner_id]
    execute %q{UPDATE rss_feeds SET owner_type = 'Affiliate'}
    execute %q{UPDATE rss_feeds SET is_video = 0 WHERE is_managed = 1}
  end

  def down
    execute %q{UPDATE rss_feeds SET is_video = 1 WHERE is_managed = 1}
    execute %q{DELETE FROM rss_feeds WHERE owner_type <> 'Affiliate'}
    remove_index :rss_feeds, column: [:owner_type, :owner_id]
    remove_column :rss_feeds, :owner_type
    rename_column :rss_feeds, :owner_id, :affiliate_id
  end
end
