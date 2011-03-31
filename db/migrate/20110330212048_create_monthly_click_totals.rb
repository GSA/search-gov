class CreateMonthlyClickTotals < ActiveRecord::Migration
  def self.up
    create_table :monthly_click_totals do |t|
      t.integer :year
      t.integer :month
      t.string :source
      t.integer :total

      t.timestamps
    end
    add_index :monthly_click_totals, [:year, :month]
  end

  def self.down
    drop_table :monthly_click_totals
  end
end
