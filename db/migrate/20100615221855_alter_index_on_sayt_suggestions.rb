class AlterIndexOnSaytSuggestions < ActiveRecord::Migration
  def self.up
    remove_index :sayt_suggestions, :phrase
    add_index :sayt_suggestions, [:phrase, :popularity]
  end

  def self.down
    remove_index :sayt_suggestions, [:phrase, :popularity]
    add_index :sayt_suggestions, :phrase
  end
end
