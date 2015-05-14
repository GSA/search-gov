class CreateI14yDrawers < ActiveRecord::Migration
  def change
    create_table :i14y_drawers do |t|
      t.references :affiliate, null: false
      t.string :handle, null: false
      t.string :token, null: false
      t.string :description

      t.timestamps
    end
    add_index :i14y_drawers, :affiliate_id
  end
end
