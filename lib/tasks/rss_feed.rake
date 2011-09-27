namespace :usasearch do
  namespace :rss_feed do
    desc "Freshens all Affiliate RSS feeds"
    task :refresh_all => :environment do
      RssFeed.refresh_all
    end
 end
end