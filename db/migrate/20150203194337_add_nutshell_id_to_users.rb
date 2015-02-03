class AddNutshellIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nutshell_id, :integer
  end
end
