class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.integer :tweet_id, :length => 8
      t.string :tweet_text
      t.references :twitter_profile

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
