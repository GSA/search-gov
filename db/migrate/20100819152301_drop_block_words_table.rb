class DropBlockWordsTable < ActiveRecord::Migration
  def self.up
    drop_table :block_words
  end

  def self.down
    create_table :block_words do |t|
      t.string :word, :null => false
      t.timestamps
    end

    add_index :block_words, :word
  end
end
