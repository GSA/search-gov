class CreateAgencyQueries < ActiveRecord::Migration
  def self.up
    create_table :agency_queries do |t|
      t.string :phrase
      t.references :agency

      t.timestamps
    end
    add_index :agency_queries, :phrase, :unique => true
  end

  def self.down
    drop_table :agency_queries
  end
end
