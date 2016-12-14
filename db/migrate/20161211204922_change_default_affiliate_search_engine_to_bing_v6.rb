class ChangeDefaultAffiliateSearchEngineToBingV6 < ActiveRecord::Migration
  def up
    change_column :affiliates, :search_engine, :string, :null => false, :default => 'BingV6'
  end

  def down
    change_column :affiliates, :search_engine, :string, :null => false, :default => 'Bing'
  end
end
