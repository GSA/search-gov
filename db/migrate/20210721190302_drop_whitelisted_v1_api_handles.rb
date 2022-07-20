class DropWhitelistedV1ApiHandles < ActiveRecord::Migration[5.2]
  def change
    drop_table :whitelisted_v1_api_handles do |t|
      t.string :handle, index: { unique: true }

      t.timestamps
    end
  end
end
