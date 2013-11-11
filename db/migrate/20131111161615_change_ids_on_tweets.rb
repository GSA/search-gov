class ChangeIdsOnTweets < ActiveRecord::Migration
  def up
    change_column :tweets, :tweet_id, 'bigint unsigned', null: false
    change_column :tweets, :twitter_profile_id, 'bigint unsigned', null: false
  end

  def down
    change_column :tweets, :twitter_profile_id, :integer, null: true
    change_column :tweets, :tweet_id, :bigint, null: true
  end
end
