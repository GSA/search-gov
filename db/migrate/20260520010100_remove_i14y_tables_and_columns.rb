class RemoveI14yTablesAndColumns < ActiveRecord::Migration[7.0]
  def up
    execute "UPDATE affiliates SET search_engine = 'open_search' WHERE search_engine = 'search_gov'"

    drop_table :i14y_memberships if table_exists?(:i14y_memberships)
    drop_table :i14y_drawers if table_exists?(:i14y_drawers)

    if column_exists?(:affiliates, :gets_i14y_results)
      remove_column :affiliates, :gets_i14y_results
    end

    if column_exists?(:affiliates, :i14y_date_stamp_enabled)
      remove_column :affiliates, :i14y_date_stamp_enabled
    end
  end

  def down
    create_table :i14y_drawers, id: :integer do |t|
      t.string :handle, null: false
      t.string :token, null: false
      t.string :description
      t.timestamps null: false
    end

    create_table :i14y_memberships, id: :integer do |t|
      t.integer :affiliate_id, null: false
      t.integer :i14y_drawer_id, null: false
      t.timestamps null: false
    end

    add_index :i14y_memberships, [:affiliate_id, :i14y_drawer_id], unique: true
    add_index :i14y_memberships, :i14y_drawer_id

    add_column :affiliates, :gets_i14y_results, :boolean, default: false, null: false
    add_column :affiliates, :i14y_date_stamp_enabled, :boolean, default: false, null: false
  end
end
