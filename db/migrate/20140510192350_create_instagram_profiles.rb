class CreateInstagramProfiles < ActiveRecord::Migration
  def change
    create_table :instagram_profiles, id: false do |t|
      t.column :id, 'bigint PRIMARY KEY', null: false
      t.string :username, null: false

      t.timestamps
    end
  end
end
