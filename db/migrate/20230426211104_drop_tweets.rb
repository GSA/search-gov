class DropTweets < ActiveRecord::Migration[7.0]
  def change
    drop_table :tweets, id: :integer do |t|
      t.bigint "tweet_id", null: false, unsigned: true
      t.string "tweet_text"
      t.bigint "twitter_profile_id", null: false, unsigned: true
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.datetime "published_at", precision: nil
      t.text "urls", size: :medium
      t.json "safe_urls"
      t.index ["published_at"], name: "index_tweets_on_published_at"
      t.index ["tweet_id"], name: "index_tweets_on_tweet_id", unique: true
      t.index ["twitter_profile_id"], name: "index_tweets_on_twitter_profile_id"
    end
  end
end
