class PruneAffiliateFields < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :contact_name
    remove_column :affiliates, :contact_email
  end

  def self.down
    add_column :affiliates, :contact_name, :string
    add_column :affiliates, :contact_email, :string
  end
end
