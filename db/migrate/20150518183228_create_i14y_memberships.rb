class CreateI14yMemberships < ActiveRecord::Migration
  def change
    create_table :i14y_memberships do |t|
      t.references :affiliate, null: false
      t.references :i14y_drawer, null: false

      t.timestamps
    end
  end
end
