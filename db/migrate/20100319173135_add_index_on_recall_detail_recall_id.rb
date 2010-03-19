class AddIndexOnRecallDetailRecallId < ActiveRecord::Migration
  def self.up
    add_index :recall_details, :recall_id, :unique => false
  end

  def self.down
    remove_index :recall_details, :recall_id
  end
end
