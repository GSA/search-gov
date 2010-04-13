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
  
  task :create_dummy_queries_data => :environment do
    raise "Usage: rake usasearch:create_dummy_queries_data DAYS=30 WORDCOUNT=1000" unless ENV["DAYS"] and ENV["WORDCOUNT"]
    ip_addresses = ["127.0.0.1"]
    20.times { |index| ip_addresses << ip_addresses[index].next }
    Query.delete_all
    days = ENV["DAYS"].to_i
    wordcount = ENV["WORDCOUNT"].to_i
    words = []
    webster = Webster.new
    wordcount.times { words << webster.random_word }
    puts "Creating queries for the last #{days} days..."
    1.upto(days) do |offset|
      day = (days - offset).days.ago
      puts "Working on #{day.to_date}..."
      ip = "127.0.0.1"
      (rand(100) + 1).times do
        words.each { |word| Query.create(:query => word, :affiliate => "usasearch.gov", :timestamp => day, :locale => 'en', :agent => 'Mozilla/5.0', :is_bot => false, :ipaddr => ip_addresses[rand(20) + 1])}
      end
      Affiliate.all.each do |affiliate|
        (rand(100) + 1).times do
          words.each { |word| Query.create(:query => word, :affiliate => affiliate.name, :timestamp => day, :locale => 'en', :agent => 'Mozilla/5.0', :is_bot => false, :ipaddr => ip_addresses[rand(20) + 1])}
        end
      end
    end
  end
end