class AddThemeColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :theme, :string
    add_column :affiliates, :staged_theme, :string
    update "UPDATE affiliates SET theme = 'custom', staged_theme = 'custom' WHERE uses_one_serp = 1"
  end

  def self.down
    remove_column :affiliates, :staged_theme
    remove_column :affiliates, :theme
  end
end
