namespace :usasearch do
  desc "truncates and creates sample data in daily_query_stats table for the last DAYS days across WORDCOUNT different words for AFFILIATE"
  task :create_dummy_analytics_data, [:days, :wordcount, :affiliate] => [:environment] do |t, args|
    raise "Usage: rake usasearch:create_dummy_analytics_data[days,wordcount,affiliate]" if args.days.nil? or args.wordcount.nil? or args.affiliate.nil?
    DailyQueryStat.delete_all
    days = args.days.to_i
    wordcount = args.wordcount.to_i
    affiliate = args.affiliate
    words = []
    webster = Webster.new
    wordcount.times { words << webster.random_word }
    puts "Creating analytics for the last #{days} days for affiliate #{affiliate}..."
    1.upto(days) do |offset|
      day = (days - offset).days.ago
      puts "Working on #{day.to_date}..."
      words.each { |word|
        DailyQueryStat.create(:affiliate => affiliate, :day => day, :query => word, :times => rand(20)+1) rescue nil
      }
    end
  end
end