class DropMonthlyClickTotalTable < ActiveRecord::Migration
  def self.up
    drop_table :monthly_click_totals
  end

  def self.down
  end
end
