class RemoveDomainsAndStagedDomainsFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :domains
    remove_column :affiliates, :staged_domains
  end

  def self.down
    add_column :affiliates, :staged_domains, :text
    add_column :affiliates, :domains, :text
  end
end
