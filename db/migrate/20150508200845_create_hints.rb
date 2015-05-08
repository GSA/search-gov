class CreateHints < ActiveRecord::Migration
  def change
    create_table :hints do |t|
      t.string :name, null: false
      t.string :value

      t.timestamps
    end

    add_index :hints, :name, unique: true
  end
end
