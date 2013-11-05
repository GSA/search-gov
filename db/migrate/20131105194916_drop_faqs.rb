class DropFaqs < ActiveRecord::Migration
  def up
    drop_table :faqs
  end

  def down
    create_table :faqs do |t|
      t.string :url
      t.text :question
      t.text :answer
      t.integer :ranking
      t.timestamps
      t.string :locale, limit: 5, default: 'en'
    end
  end
end
