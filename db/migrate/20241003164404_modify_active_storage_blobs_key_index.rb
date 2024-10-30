class ModifyActiveStorageBlobsKeyIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :active_storage_blobs, :key

    add_index :active_storage_blobs, :key, unique: true
  end
end
