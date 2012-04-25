class ChangeTweetsTweetIdToBigint < ActiveRecord::Migration
  def self.up
    change_column :tweets, :tweet_id, :bigint
  end

  def self.down
    change_column :tweets, :tweet_id, :integer
  end
end
