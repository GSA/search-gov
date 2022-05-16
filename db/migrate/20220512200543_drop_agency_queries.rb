class DropAgencyQueries < ActiveRecord::Migration[6.1]
  def up
    drop_table :agency_queries
  end

  def down
    create_table :agency_queries do |t|
      t.string :phrase
      t.references :agency

      t.timestamps
    end
    add_index :agency_queries, :phrase, :unique => true
  end
end
