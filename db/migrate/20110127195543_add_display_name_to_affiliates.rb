class AddDisplayNameToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :display_name, :string, :null => false
    update("update affiliates set display_name = name")
  end

  def self.down
    remove_column :affiliates, :display_name
  end
end
