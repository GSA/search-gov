class CreateFaqs < ActiveRecord::Migration
  def self.up
    create_table :faqs do |t|
      t.string :url
      t.text :question
      t.text :answer
      t.integer :ranking
      t.timestamps
    end
  end

  def self.down
    drop_table :faqs
  end
end
