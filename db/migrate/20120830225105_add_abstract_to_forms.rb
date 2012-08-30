class AddAbstractToForms < ActiveRecord::Migration
  def change
    add_column :forms, :abstract, :text
  end
end
