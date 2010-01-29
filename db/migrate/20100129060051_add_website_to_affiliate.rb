class AddWebsiteToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :website, :string
  end

  def self.down
    remove_column :affiliates, :website
  end
end
