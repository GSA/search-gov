class CreateBlockWords < ActiveRecord::Migration
  def self.up
    create_table :block_words do |t|
      t.string :word, :null => false
      t.timestamps
    end

    add_index :block_words, :word
  end

  def self.down
    drop_table :block_words
  end
end
