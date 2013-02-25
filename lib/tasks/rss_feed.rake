namespace :usasearch do
  namespace :rss_feed do
    desc 'Refresh non managed feeds'
    task :refresh_non_managed_feeds => :environment do
      RssFeed.refresh_non_managed_feeds
    end

    desc 'Freshen managed feeds'
    task :refresh_managed_feeds, [:max_news_items_count] => :environment do |t, args|
      if args.max_news_items_count.present?
        RssFeed.refresh_managed_feeds(args.max_news_items_count.to_i)
      else
        RssFeed.refresh_managed_feeds
      end
    end
 end
end