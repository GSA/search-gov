class ChangeDefaultAffiliatesResultsSourceToBingOdie < ActiveRecord::Migration
  def self.up
    change_column :affiliates, :results_source, :string, :default => 'bing+odie', :limit => 15
  end

  def self.down
    change_column :affiliates, :results_source, :string, :default => 'bing'
  end
end
