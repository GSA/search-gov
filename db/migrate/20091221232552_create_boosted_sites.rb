class CreateBoostedSites < ActiveRecord::Migration
  def self.up
    create_table :boosted_sites do |t|
      t.references :affiliate, :null => false
      t.string :title, :null => false
      t.string :url, :null => false
      t.string :description, :null => false
      t.timestamp(:created_at)
    end

    add_index :boosted_sites, :affiliate_id
  end

  def self.down
    drop_table :boosted_sites
  end
end
