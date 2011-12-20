class RemovePriorTruncatedIndexedDocs < ActiveRecord::Migration
  def self.up
    execute "delete from indexed_documents where length(url)=255 or length(title)=255"
  end

  def self.down
  end
end
