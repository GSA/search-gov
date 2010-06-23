class AddFoodTypeToFoodRecalls < ActiveRecord::Migration
  def self.up
    add_column :food_recalls, :food_type, :string, :limit => 10
    FoodRecall.all.each do |food_recall|
      food_recall.update_attributes(:food_type => "food")
    end
  end

  def self.down
    remove_column :food_recalls, :food_type
  end
end
