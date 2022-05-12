class DropAgencyQueries < ActiveRecord::Migration[6.1]
  def up
    drop_table :agency_queries
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore dropped agency_queries table."
  end

end
