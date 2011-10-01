class TruncateExistingNewsItems < ActiveRecord::Migration
  def self.up
    NewsItem.destroy_all
    Sunspot.commit
  end

  def self.down
  end
end
