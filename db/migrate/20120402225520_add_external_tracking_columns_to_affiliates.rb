class AddExternalTrackingColumnsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :wt_javascript_url, :string
    add_column :affiliates, :wt_dcsimg_hash, :string, :limit => 50
    add_column :affiliates, :wt_dcssip, :string, :limit => 50
    add_column :affiliates, :ga_web_property_id, :string, :limit => 20
  end

  def self.down
    remove_column :affiliates, :wt_javascript_url
    remove_column :affiliates, :wt_dcsimg_hash
    remove_column :affiliates, :wt_dcssip
    remove_column :affiliates, :ga_web_property_id
  end
end
