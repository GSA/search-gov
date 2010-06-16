class AddPopularityToSaytSuggestions < ActiveRecord::Migration
  def self.up
    add_column :sayt_suggestions, :popularity, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :sayt_suggestions, :popularity
  end
end
