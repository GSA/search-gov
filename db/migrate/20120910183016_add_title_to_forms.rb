class AddTitleToForms < ActiveRecord::Migration
  def change
    add_column :forms, :title, :string, :null => false
    add_index :forms, :title
  end
end
