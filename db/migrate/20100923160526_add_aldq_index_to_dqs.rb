class AddAldqIndexToDqs < ActiveRecord::Migration
  def self.up
    add_index :daily_query_stats, [:affiliate, :locale, :day, :query], :unique=> true, :name=>"aldq"
  end

  def self.down
    remove_index :daily_query_stats, :name=>"aldq"
  end
end
