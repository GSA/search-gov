class CreateKeenScopedKeys < ActiveRecord::Migration
  def change
    create_table :scoped_keys do |t|
      t.references :affiliate
      t.text :key, null: false

      t.timestamps
    end
    add_index :scoped_keys, :affiliate_id, unique: true
  end
end
