class AddUsesManagedHeaderFooterColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :uses_managed_header_footer, :boolean
    add_column :affiliates, :staged_uses_managed_header_footer, :boolean
  end

  def self.down
    remove_column :affiliates, :staged_uses_managed_header_footer
    remove_column :affiliates, :uses_managed_header_footer
  end
end
