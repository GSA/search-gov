namespace :usasearch do
  namespace :rss_feed do
    desc "Freshens Affiliate RSS feeds"
    task :refresh_all, :freshen_managed_feeds, :needs => :environment do |t, args|
      RssFeed.refresh_all(args.freshen_managed_feeds == 'true')
    end
 end
end