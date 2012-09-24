class ConvertTweetTcoToFullUrls < ActiveRecord::Migration
  def up
    Tweet.where('tweet_text LIKE "%://t.co/%"').each do |tweet|
      begin
        tweet.convert_tco_links
        tweet.save!
      rescue Exception => exception
        puts "Could not update Tweet ##{tweet.id}: #{exception.message}"
        puts exception.backtrace.join("\n")
      end
    end
  end

  def down
    puts "Sorry! This migration cannot be reverted."
  end
end
