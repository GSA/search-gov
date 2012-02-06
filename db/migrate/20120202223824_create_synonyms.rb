class CreateSynonyms < ActiveRecord::Migration
  def self.up
    create_table :synonyms do |t|
      t.string :phrase
      t.string :alias
      t.string :source

      t.timestamps
    end
    add_index :synonyms, [:phrase, :alias]
  end

  def self.down
    drop_table :synonyms
  end
end
