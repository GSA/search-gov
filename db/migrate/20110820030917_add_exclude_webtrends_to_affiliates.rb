class AddExcludeWebtrendsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :exclude_webtrends, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :affiliates, :exclude_webtrends
  end
end
