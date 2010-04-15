class DestroyAllClicks < ActiveRecord::Migration
  def self.up
    Click.destroy_all
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted data"  
  end
end
