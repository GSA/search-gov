class DropTemplatesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :templates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
