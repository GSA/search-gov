namespace :usasearch do
  namespace :bitly do    
    desc "Compute most popular links for a given date"
    task :compute_popular_urls, :date, :needs => :environment do |t, args|
      args.with_defaults(:date => Date.yesterday.to_s(:number))
      day = Date.parse(args.date)
      AgencyPopularUrl.compute_for_date(day)
    end
  end
end