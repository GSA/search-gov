class CreateSaytSuggestions < ActiveRecord::Migration
  def self.up
    create_table :sayt_suggestions do |t|
      t.string :phrase, :null => false
      t.timestamp(:created_at)
    end
    add_index :sayt_suggestions, :phrase, :unique => true
  end

  def self.down
    drop_table :sayt_suggestions
  end
end
