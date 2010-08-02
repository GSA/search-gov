class CreateCalaisRelatedSearches < ActiveRecord::Migration
  def self.up
    create_table :calais_related_searches do |t|
      t.string :term
      t.string :related_terms, :limit => 4096

      t.timestamps
    end
  end

  def self.down
    drop_table :calais_related_searches
  end
end
