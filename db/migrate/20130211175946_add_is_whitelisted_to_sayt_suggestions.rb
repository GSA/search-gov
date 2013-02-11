class AddIsWhitelistedToSaytSuggestions < ActiveRecord::Migration
  def change
    add_column :sayt_suggestions, :is_whitelisted, :boolean, :null => false, :default => false
  end
end
