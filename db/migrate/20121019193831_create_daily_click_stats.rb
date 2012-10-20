class CreateDailyClickStats < ActiveRecord::Migration
  def change
    create_table :daily_click_stats do |t|
      t.string :affiliate, :null => false, :limit => 32
      t.date :day, :null => false
      t.string :url, :null => false, :limit => 2000
      t.integer :times, :null => false
    end
    add_index :daily_click_stats, [:affiliate, :day]
  end
end
