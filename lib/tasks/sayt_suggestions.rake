namespace :usasearch do
  namespace :sayt_suggestions do

    desc "generate SAYT suggestions from DailyQueryStats table for given YYYYMMDD date (defaults to yesterday)"
    task :compute, :day, :needs => :environment do |t, args|
      args.with_defaults(:day => Date.yesterday.to_s(:number))
      yyyymmdd = args.day.to_i
      SaytSuggestion.populate_for(yyyymmdd)
    end
  end
end