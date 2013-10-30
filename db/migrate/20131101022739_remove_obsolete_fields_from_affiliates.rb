class RemoveObsoleteFieldsFromAffiliates < ActiveRecord::Migration
  def up
    remove_column :affiliates, :staged_external_css_url
    remove_column :affiliates, :staged_favicon_url
    remove_column :affiliates, :staged_css_properties
    remove_column :affiliates, :staged_theme
    remove_column :affiliates, :is_twitter_govbox_enabled
  end

  def down
    add_column :affiliates, :is_twitter_govbox_enabled, :boolean, default: false
    add_column :affiliates, :staged_theme, :string
    add_column :affiliates, :staged_css_properties, :text
    add_column :affiliates, :staged_favicon_url, :string
    add_column :affiliates, :staged_external_css_url, :string
  end
end
