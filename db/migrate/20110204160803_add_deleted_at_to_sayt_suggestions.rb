class AddDeletedAtToSaytSuggestions < ActiveRecord::Migration
  def self.up
    add_column :sayt_suggestions, :deleted_at, :timestamp, :default => nil
  end

  def self.down
    remove_column :sayt_suggestions, :deleted_at
  end
end
