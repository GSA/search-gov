class CreateIndexedDomain < ActiveRecord::Migration
  def self.up
    create_table :indexed_domains do |t|
      t.references :affiliate, :null => false
      t.string :domain, :null => false
    end
    add_index :indexed_domains, [:affiliate_id, :domain], :unique => true
    add_index :indexed_domains, :domain
  end

  def self.down
    drop_table :indexed_domains
  end
end
