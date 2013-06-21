namespace :usasearch do
  namespace :site_feed_url do
    desc 'Refresh site feeds to find new docs to index'
    task :refresh_all => :environment do
      SiteFeedUrl.refresh_all
    end
 end
end