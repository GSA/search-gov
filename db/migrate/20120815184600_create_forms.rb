class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :agency, :null => false
      t.string :number, :null => false
      t.string :url, :null => false
      t.string :file_type, :null => false
      t.text :details

      t.timestamps
    end
  end
end
