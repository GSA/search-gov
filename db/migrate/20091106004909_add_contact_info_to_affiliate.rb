class AddContactInfoToAffiliate < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :contact_name, :string
    add_column :affiliates, :contact_email, :string
  end

  def self.down
    remove_column :affiliates, :contact_name, :string
    remove_column :affiliates, :contact_email, :string
  end
end
