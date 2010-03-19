class ChangeRecallNumberToString < ActiveRecord::Migration
  def self.up
    change_column :recalls, :recall_number, :string, :limit => 10
  end

  def self.down
    change_column :recalls, :recall_number, :integer
  end
end
