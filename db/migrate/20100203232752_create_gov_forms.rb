class CreateGovForms < ActiveRecord::Migration
  def self.up
    create_table :gov_forms do |t|
      t.string :name, :null => false
      t.string :form_number, :null => false
      t.string :agency, :null => false
      t.string :bureau
      t.text :description
      t.string :url, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :gov_forms
  end
end
