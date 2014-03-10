namespace :usasearch do
  namespace :rss_feed_urls do
    desc 'Enqueue destroy all inactive'
    task :enqueue_destroy_all_inactive => :environment do
      RssFeedUrl.enqueue_destroy_all_inactive
    end

    desc 'Enqueue destroy all news items with 404'
    task :enqueue_destroy_all_news_items_with_404 => :environment do
      RssFeedUrl.enqueue_destroy_all_news_items_with_404
    end
  end
end
