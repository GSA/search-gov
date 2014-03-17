class CreateTweetIndex < ActiveRecord::Migration
  def up
    ElasticTweet.create_index unless ElasticTweet.index_exists?
  end

  def down
    ElasticTweet.delete_index if ElasticTweet.index_exists?
  end
end
