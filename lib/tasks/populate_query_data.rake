namespace :usasearch do
  desc "truncates and creates sample data in daily_query_stats&query_acceleration tables for the last DAYS days across WORDCOUNT different words"
  task :create_dummy_analytics_data => :environment do
    raise "Usage: rake usasearch:create_dummy_analytics_data DAYS=30 WORDCOUNT=1000" unless ENV["DAYS"] and ENV["WORDCOUNT"]
    DailyQueryStat.delete_all
    days = ENV["DAYS"].to_i
    wordcount = ENV["WORDCOUNT"].to_i
    words = []
    webster = Webster.new
    wordcount.times { words << webster.random_word }
    puts "Creating analytics for the last #{days} days..."
    1.upto(days) do |offset|
      day = (days - offset).days.ago
      puts "Working on #{day.to_date}..."
      words.each { |word| DailyQueryStat.create(:day => day, :query => word, :times => rand(20)+1) rescue nil }
    end
  end
end