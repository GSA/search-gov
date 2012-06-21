class AddLoadTimeToIndexedDocument < ActiveRecord::Migration
  def self.up
    add_column :indexed_documents, :load_time, :integer
  end

  def self.down
    remove_column :indexed_documents, :load_time
  end
end
