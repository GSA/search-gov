class CreateElasticIndexedDocumentIndex < ActiveRecord::Migration
  def up
    ElasticIndexedDocument.create_index unless ElasticIndexedDocument.index_exists?
  end

  def down
    ElasticIndexedDocument.delete_index if ElasticIndexedDocument.index_exists?
  end
end
