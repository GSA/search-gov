class DropTags < ActiveRecord::Migration
  def up
    drop_table :tags
  end

  def down
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :tags, :name, unique: true
  end
end
