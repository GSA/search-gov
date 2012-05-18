class RemoveWebTrendsColumnsFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :wt_javascript_url
    remove_column :affiliates, :wt_dcsimg_hash
    remove_column :affiliates, :wt_dcssip
  end

  def self.down
    add_column :affiliates, :wt_javascript_url, :string
    add_column :affiliates, :wt_dcsimg_hash, :string, :limit => 50
    add_column :affiliates, :wt_dcssip, :string, :limit => 50
  end
end
