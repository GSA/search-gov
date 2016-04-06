class ChangeDefaultAffiliateSearchEngineBackToBing < ActiveRecord::Migration
  def up
    change_column :affiliates, :search_engine, :string, :null => false, :default => 'Bing'
  end

  def down
    change_column :affiliates, :search_engine, :string, :null => false, :default => 'Azure'
  end
end
