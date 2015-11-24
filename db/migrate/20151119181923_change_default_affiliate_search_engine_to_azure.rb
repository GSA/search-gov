class ChangeDefaultAffiliateSearchEngineToAzure < ActiveRecord::Migration
  def up
    change_column :affiliates, :search_engine, :string, :null => false, :default => 'Azure'
  end

  def down
    change_column :affiliates, :search_engine, :string, :null => false, :default => 'Bing'
  end
end
