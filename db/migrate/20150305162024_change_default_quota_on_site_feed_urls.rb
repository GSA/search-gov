class ChangeDefaultQuotaOnSiteFeedUrls < ActiveRecord::Migration
  def up
    change_column_default :site_feed_urls, :quota, 1000
  end

  def down
    change_column_default :site_feed_urls, :quota, 500
  end
end
