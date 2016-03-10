class AddTypeToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :type, :string, index: true
  end
end
