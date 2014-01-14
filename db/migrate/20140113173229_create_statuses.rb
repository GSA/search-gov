class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.integer :id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :statuses, :name, unique: true
  end
end
