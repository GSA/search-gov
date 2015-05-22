class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.boolean :is_google_supported, null: false, default: false
      t.boolean :is_bing_supported, null: false, default: false
      t.boolean :rtl, null: false, default: false

      t.timestamps
    end
    add_index :languages, :code, unique: true
  end
end
