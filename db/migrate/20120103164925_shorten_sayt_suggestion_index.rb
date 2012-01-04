class ShortenSaytSuggestionIndex < ActiveRecord::Migration
  def self.up
    remove_index :sayt_suggestions, :name => "index_sayt_suggestions_on_aff_id_phrase_del_at_pop"
    add_index :sayt_suggestions, [:affiliate_id, :phrase], :unique => true
  end

  def self.down
    remove_index :sayt_suggestions, [:affiliate_id, :phrase]
    add_index :sayt_suggestions, [:affiliate_id, :phrase, :deleted_at, :popularity], :name => "index_sayt_suggestions_on_aff_id_phrase_del_at_pop", :unique => true
  end
end
