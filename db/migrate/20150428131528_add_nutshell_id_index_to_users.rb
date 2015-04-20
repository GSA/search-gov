class AddNutshellIdIndexToUsers < ActiveRecord::Migration
  def up
    add_index :users, :nutshell_id
  end

  def down
    remove_index :users, :nutshell_id
  end
end
