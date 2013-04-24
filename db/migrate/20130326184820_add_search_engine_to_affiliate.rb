class AddSearchEngineToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :search_engine, :string, :null => false, :default => 'Bing'
  end
end
