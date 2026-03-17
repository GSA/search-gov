class ChangeDefaultSearchEngineOnAffiliates < ActiveRecord::Migration[7.1]
  def change
    change_column_default :affiliates, :search_engine, from: 'SearchElastic', to: 'OpenSearch'
  end
end
