class AddResultsSourceClickedAtIndexToClicks < ActiveRecord::Migration
  def self.up
    add_index :clicks, [:results_source, :clicked_at]
  end

  def self.down
    remove_index :clicks, [:results_source, :clicked_at]
  end
end
