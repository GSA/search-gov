class AddGetsRefreshedToCalaisRelatedSearch < ActiveRecord::Migration
  def self.up
    add_column :calais_related_searches, :gets_refreshed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :calais_related_searches, :gets_refreshed
  end
end
