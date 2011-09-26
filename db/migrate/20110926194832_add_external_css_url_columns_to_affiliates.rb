class AddExternalCssUrlColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :external_css_url, :string
    add_column :affiliates, :staged_external_css_url, :string
  end

  def self.down
    remove_column :affiliates, :staged_external_css_url
    remove_column :affiliates, :external_css_url
  end
end
