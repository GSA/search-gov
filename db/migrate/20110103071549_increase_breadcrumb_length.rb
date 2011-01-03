class IncreaseBreadcrumbLength < ActiveRecord::Migration
  def self.up
    change_column :site_pages, :breadcrumb, :string, :limit => 2048
  end

  def self.down
    change_column :site_pages, :breadcrumb, :string, :limit => 255    
  end
end
