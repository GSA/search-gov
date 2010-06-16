namespace :usasearch do
  namespace :sayt_suggestions do

    desc "generate SAYT suggestions from DailyQueryStats table for given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      SaytSuggestion.populate_for(yyyymmdd)
    end

    desc "expire SAYT suggestions that have not been updated in X days (defaults to 30)"
    task :expire, :days_back, :needs => :environment do |t, args|
      args.with_defaults(:days_back => 30)
      SaytSuggestion.expire(args.days_back)
    end
  end
end