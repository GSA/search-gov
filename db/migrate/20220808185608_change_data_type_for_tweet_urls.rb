class ChangeDataTypeForTweetUrls < ActiveRecord::Migration[6.1]
  def up
    # create a faux model to avoid JSON parsing of still-YAML content
    faux_tweets = Class.new ActiveRecord::Base
    faux_tweets.table_name = 'tweets'

    faux_tweets.select([:id, :urls]).find_in_batches do |tweets|
      tweets.each do |tweet|
        begin
          next if tweet.urls.nil?

          tweet.urls = YAML.load(tweet.urls).to_json
          tweet.save!

        rescue Exception => e
          puts "Could not fix tweet #{tweet.id} for #{e.message}"
        end
      end
    end

    change_column :tweets, :urls, :json
  end

  def down
    change_column :tweets, :urls, :text
  end
end
