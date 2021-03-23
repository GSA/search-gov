class AddIndexOnTweetsPublishedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :tweets, :published_at
  end
end
