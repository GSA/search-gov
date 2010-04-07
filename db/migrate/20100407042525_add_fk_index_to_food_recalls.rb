class AddFkIndexToFoodRecalls < ActiveRecord::Migration
  def self.up
    add_index :food_recalls, :recall_id
  end

  def self.down
    remove_index :food_recalls, :recall_id
  end
end
