class CreateTopSearches < ActiveRecord::Migration
  def self.up
    create_table :top_searches do |t|
      t.string :query
      t.string :url
      t.integer :position

      t.timestamps
    end
    add_index :top_searches, :position, :unique => true
    1.upto(5) do |index|
      TopSearch.create(:position => index, :query => "Top Search #{index}")
    end
  end

  def self.down
    drop_table :top_searches
  end
end
