class AddRocisColumnsToForms < ActiveRecord::Migration
  def change
    add_column :forms, :line_of_business, :string
    add_column :forms, :subfunction, :string
    add_column :forms, :public_code, :string
  end
end
