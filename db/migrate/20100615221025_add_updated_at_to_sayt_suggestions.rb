class AddUpdatedAtToSaytSuggestions < ActiveRecord::Migration
  def self.up
    add_column :sayt_suggestions, :updated_at, :datetime
  end

  def self.down
    remove_column :sayt_suggestions, :updated_at
  end
end
