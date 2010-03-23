class AddOrganizationToRecalls < ActiveRecord::Migration
  def self.up
    add_column :recalls, :organization, :string, :limit => 10
  end

  def self.down
    remove_column :recalls, :organization
  end
end
