class AddFaviconUrlColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :favicon_url, :string
    add_column :affiliates, :staged_favicon_url, :string
  end

  def self.down
    remove_column :affiliates, :staged_favicon_url
    remove_column :affiliates, :favicon_url
  end
end
