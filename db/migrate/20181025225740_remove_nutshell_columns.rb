class RemoveNutshellColumns < ActiveRecord::Migration
  def change
    remove_index :users, column: :nutshell_id
    remove_column :users, :nutshell_id, :integer
    remove_column :affiliates, :nutshell_id, :integer
  end
end
