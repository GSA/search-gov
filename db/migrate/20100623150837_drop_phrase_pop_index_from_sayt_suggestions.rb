class DropPhrasePopIndexFromSaytSuggestions < ActiveRecord::Migration
  def self.up
    remove_index :sayt_suggestions, [:phrase, :popularity]
  end

  def self.down
    add_index :sayt_suggestions, [:phrase, :popularity]
  end
end
