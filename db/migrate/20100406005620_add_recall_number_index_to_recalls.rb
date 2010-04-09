class AddRecallNumberIndexToRecalls < ActiveRecord::Migration
  def self.up
    add_index :recalls, :recall_number, :unique => false
  end

  def self.down
    remove_index :recalls, :recall_number
  end
end
