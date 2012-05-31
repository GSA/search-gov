namespace :usasearch do
  namespace :flickr do

    desc "Connect to Twitter Streaming API and capture tweets from all customer twitter accounts"
    task :import_photos => :environment do
      Affiliate.all.each{|affiliate| affiliate.import_flickr_photos }
    end
  end
end
    