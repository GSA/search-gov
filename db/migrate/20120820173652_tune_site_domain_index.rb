class TuneSiteDomainIndex < ActiveRecord::Migration
  def up
    remove_index :site_domains, :affiliate_id
    add_index :site_domains, [:affiliate_id, :domain], :unique => true
  end

  def down
    remove_index :site_domains, [:affiliate_id, :domain]
    add_index :site_domains, :affiliate_id
  end
end
