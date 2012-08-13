class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :agency
      t.string :number
      t.string :url
      t.text :details

      t.timestamps
    end
  end
end
