class CreateSynonyms < ActiveRecord::Migration
  def change
    create_table :synonyms do |t|
      t.string :entry, null: false
      t.text :notes
      t.string :status, null: false, default: 'Candidate'
      t.string :locale, null: false

      t.timestamps
    end
    add_index :synonyms, [:entry, :locale], unique: true
  end
end
