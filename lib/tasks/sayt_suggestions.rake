namespace :usasearch do
  namespace :sayt_suggestions do

    desc 'generate top X SAYT suggestions from human Logstash searches
      for given YYYYMMDD date (defaults to 1000 for yesterday)'.squish
    task :compute, [:day, :limit] => [:environment] do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      limit = args.limit.nil? ? 1000 : args.limit.to_i
      SaytSuggestion.populate_for(yyyymmdd, limit)
    end

    desc 'expire SAYT suggestions that have not been updated in X days (defaults to 30)'
    task :expire, [:days_back] => [:environment] do |t, args|
      args.with_defaults(:days_back => 30)
      SaytSuggestion.expire(args.days_back.to_i)
    end
  end
end
