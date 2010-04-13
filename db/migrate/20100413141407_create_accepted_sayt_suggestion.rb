class CreateAcceptedSaytSuggestion < ActiveRecord::Migration
  def self.up
    create_table :accepted_sayt_suggestions do |t|
      t.string :phrase, :null => false
      t.timestamp(:created_at)
    end
  end

  def self.down
    drop_table :accepted_sayt_suggestions
  end
end
