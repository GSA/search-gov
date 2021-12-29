class AddCreatedAtAndDeletedAtToFoodRecalls < ActiveRecord::Migration
  def self.up
    add_column :food_recalls, :created_at, :datetime
    add_column :food_recalls, :updated_at, :datetime
    FoodRecall.all.each do |food_recall|
      food_recall.update(:created_at => food_recall.recall.created_at, :updated_at => food_recall.recall.updated_at) if food_recall.recall.present?
    end
  end

  def self.down
    remove_column :food_recalls, :created_at
    remove_column :food_recalls, :updated_at
  end
end
