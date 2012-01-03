class CreateSiteDomains < ActiveRecord::Migration
  def self.up
    create_table :site_domains do |t|
      t.references :affiliate, :null => false
      t.string :site_name, :null => false
      t.string :domain, :null => false
      t.timestamps
    end
    add_index :site_domains, :affiliate_id
  end

  def self.down
    drop_table :site_domains
  end
end
