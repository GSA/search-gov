namespace :usasearch do
  require 'webster'
  desc "truncates and creates sample data in daily_query_stats&query_acceleration tables for the last DAYS days across WORDCOUNT different words"
  task :create_dummy_analytics_data => :environment do
    raise "Usage: rake usasearch:create_dummy_analytics_data DAYS=30 WORDCOUNT=1000" unless ENV["DAYS"] and ENV["WORDCOUNT"]
    DailyQueryStat.delete_all
    QueryAcceleration.delete_all
    days = ENV["DAYS"].to_i
    wordcount = ENV["WORDCOUNT"].to_i
    words = []
    webster = Webster.new
    wordcount.times { words << webster.random_word }
    puts "Creating analytics for the last #{days} days..."
    1.upto(days) do |offset|
      day = (days - offset).days.ago
      puts "Working on #{day.to_date}..."
      words.each do |word|
        times = rand(1000)
        DailyQueryStat.create(:day => day, :query => word, :times => times)
        [1, 7, 30].each { |window_size| QueryAcceleration.create(:day => day, :query => word, :window_size => window_size, :score => rand(100) ) }
      end
    end
  end
end