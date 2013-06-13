class DropIndexedDomains < ActiveRecord::Migration
  def up
    drop_table :indexed_domains
  end

  def down
    create_table "indexed_domains", :force => true do |t|
      t.integer "affiliate_id", :null => false
      t.string  "domain",       :null => false
    end

    add_index "indexed_domains", ["affiliate_id", "domain"], :name => "index_indexed_domains_on_affiliate_id_and_domain", :unique => true
    add_index "indexed_domains", ["domain"], :name => "index_indexed_domains_on_domain"
  end
end
