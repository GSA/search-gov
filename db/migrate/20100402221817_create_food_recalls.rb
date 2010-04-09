class CreateFoodRecalls < ActiveRecord::Migration
  def self.up
    create_table :food_recalls do |t|
      t.references :recall
      t.string :summary, :null => false
      t.text :description, :null => false
      t.string :url, :null => false
    end
  end

  def self.down
    drop_table :food_recalls
  end
end
