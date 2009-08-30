namespace :usasearch do
  require 'webster'
  desc "truncates and creates sample data in daily_query_stats table for the last DAYS days"
  task :create_dummy_daily_query_stats_data => :environment do
    raise "Usage: rake usasearch:create_dummy_daily_query_stats_data DAYS=30 WORDCOUNT=1000" unless ENV["DAYS"] and ENV["WORDCOUNT"]
    DailyQueryStat.delete_all
    days = ENV["DAYS"].to_i
    wordcount = ENV["WORDCOUNT"].to_i
    words = []
    webster = Webster.new
    wordcount.times { words << webster.random_word  }
    puts "Creating daily query stats for the last #{days} days..."
    1.upto(days) do |offset|
      day = (days - offset).days.ago
      puts "Working on #{day.to_date}..."
      wordcount.times { DailyQueryStat.create(:day => day, :query => words[rand(wordcount)], :times => rand(1000)) rescue nil }
    end
  end
end