class DropAcceptedSaytSuggestion < ActiveRecord::Migration
  def self.up
    drop_table :accepted_sayt_suggestions
  end

  def self.down
    create_table :accepted_sayt_suggestions do |t|
      t.string :phrase, :null => false
      t.timestamp(:created_at)
    end
  end
end
