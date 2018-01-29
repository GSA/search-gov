class DropScopedKeys < ActiveRecord::Migration
  def up
    drop_table :scoped_keys
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore dropped scoped_keys table"
  end
end
