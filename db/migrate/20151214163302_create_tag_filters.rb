class CreateTagFilters < ActiveRecord::Migration
  def change
    create_table :tag_filters do |t|
      t.references :affiliate, null: false
      t.string :tag
      t.boolean :exclude

      t.timestamps
    end
    add_index :tag_filters, :affiliate_id
  end
end
