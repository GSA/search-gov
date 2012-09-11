class RemoveAffiliateFields < ActiveRecord::Migration
  def up
    remove_column :affiliates, :is_odie_govbox_enabled
    remove_column :affiliates, :results_source
  end

  def down
    add_column :affiliates, :is_odie_govbox_enabled, :boolean, :null => false, :default => true
    add_column :affiliates, :results_source, :string, :default => 'bing+odie'
  end
end
