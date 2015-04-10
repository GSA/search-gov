class CreateWhitelistedV1ApiHandles < ActiveRecord::Migration
  def change
    create_table :whitelisted_v1_api_handles do |t|
      t.string :handle

      t.timestamps
    end
  end
end
