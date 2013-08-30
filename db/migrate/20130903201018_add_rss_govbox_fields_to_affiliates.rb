class AddRssGovboxFieldsToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :is_rss_govbox_enabled, :boolean, default: false, null: false
    add_column :affiliates, :rss_govbox_label, :string, null: false
  end
end
