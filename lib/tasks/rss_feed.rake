namespace :usasearch do
  namespace :rss_feed do
    desc 'Refresh Affiliate owned rss feeds'
    task :refresh_affiliate_feeds => :environment do
      RssFeedUrl.refresh_affiliate_feeds
    end
 end
end
