class DropStatusesTable < ActiveRecord::Migration
  def up
    drop_table :statuses
    remove_column :affiliates, :status_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
