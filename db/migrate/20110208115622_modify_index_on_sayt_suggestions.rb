class ModifyIndexOnSaytSuggestions < ActiveRecord::Migration
  def self.up
    remove_index :sayt_suggestions, [:affiliate_id, :phrase, :popularity]
    add_index :sayt_suggestions, [:affiliate_id, :phrase, :deleted_at, :popularity], :unique => true, :name => "index_sayt_suggestions_on_aff_id_phrase_del_at_pop"
  end

  def self.down
    remove_index :sayt_suggestions, 'aff_id_phrase_del_at_pop'
    add_index :sayt_suggestions, [:affiliate_id, :phrase, :popularity], :unique => true    
  end
end
