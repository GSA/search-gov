class CreateElasticFederalRegisterDocumentIndex < ActiveRecord::Migration
  def up
    ElasticFederalRegisterDocument.create_index unless ElasticFederalRegisterDocument.index_exists?
  end

  def down
    ElasticFederalRegisterDocument.delete_index if ElasticFederalRegisterDocument.index_exists?
  end
end
