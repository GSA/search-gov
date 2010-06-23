class AddAffPhrasePopIndexToSaytSuggestions < ActiveRecord::Migration
  def self.up
    add_index :sayt_suggestions, [:affiliate_id, :phrase, :popularity], :unique => true
  end

  def self.down
    remove_index :sayt_suggestions, [:affiliate_id, :phrase, :popularity]
  end
end
