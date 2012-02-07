class DropSynonyms < ActiveRecord::Migration
  def self.up
    drop_table :synonyms
  end

  def self.down
    create_table :synonyms do |t|
      t.string :phrase
      t.string :alias
      t.string :source

      t.timestamps
    end
    add_index :synonyms, [:phrase, :alias]
  end
end
