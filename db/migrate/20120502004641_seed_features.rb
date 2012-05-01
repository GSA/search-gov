class SeedFeatures < ActiveRecord::Migration
  class Feature < ActiveRecord::Base
  end

  def self.up
    Feature.create(:internal_name => "sayt", :display_name => "Type-ahead Search")
    Feature.create(:internal_name => "disco", :display_name => "Discovery Tag")
    Feature.create(:internal_name => "hosted_sitemaps", :display_name => "Hosted Sitemaps")
    Feature.create(:internal_name => "social", :display_name => "Social Media Handles")
    Feature.create(:internal_name => "rss", :display_name => "News RSS Feeds")
    Feature.create(:internal_name => "top_picks", :display_name => "Editor's Top Searches")
    Feature.create(:internal_name => "best_bets", :display_name => "Best Bets")
    Feature.create(:internal_name => "collections", :display_name => "Document Collections")
    Feature.create(:internal_name => "search_traffic", :display_name => "Search Traffic")
  end

  def self.down
    Feature.destroy_all
  end
end
