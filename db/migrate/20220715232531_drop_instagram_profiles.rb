class DropInstagramProfiles < ActiveRecord::Migration[6.1]
  def change
    drop_table :instagram_profiles, id: :bigint, default: nil do |t|
      t.string "username", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
