class CreateElasticSaytSuggestions < ActiveRecord::Migration
  def up
    ElasticSaytSuggestion.create_index unless ElasticSaytSuggestion.index_exists?
  end

  def down
    ElasticSaytSuggestion.delete_index if ElasticSaytSuggestion.index_exists?
  end
end
