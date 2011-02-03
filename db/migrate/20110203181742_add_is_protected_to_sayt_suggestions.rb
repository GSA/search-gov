class AddIsProtectedToSaytSuggestions < ActiveRecord::Migration
  def self.up
    add_column :sayt_suggestions, :is_protected, :boolean, :default => false
  end

  def self.down
    remove_column :sayt_suggestions, :is_protected
  end
end
