class ChangeSearchEngineFromAffiliates < ActiveRecord::Migration[7.1]
  def change
    change_column :affiliates, :search_engine, :string, default: 'SearchElastic'
  end
end
