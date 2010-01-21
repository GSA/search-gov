class AlterClicks < ActiveRecord::Migration
  def self.up
    drop_table :clicks
    create_table :clicks do |t|
      t.string :query
      t.datetime :queried_at
      t.string :url
      t.integer :serp_position
      t.string :property_used
      t.timestamps
    end
  end

  def self.down
    create_table :clicks do |t|
      t.string :domain
      t.integer :count

      t.timestamps
    end
  end
end
