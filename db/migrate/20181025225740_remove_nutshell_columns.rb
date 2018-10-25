class RemoveNutshellColumns < ActiveRecord::Migration
  def change
    remove_index :users, :nutshell_id
    remove_column :users, :nutshell_id, :integer
    remove_column :affiliates, :nutshell_id, :integer
  end
end
