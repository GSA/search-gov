class ChangeForms < ActiveRecord::Migration
  def up
    change_table :forms do |t|
      t.remove :agency
      t.references :form_agency, :null => false
      t.index :form_agency_id
    end
  end

  def down
    change_table :forms do |t|
      t.remove_index :form_agency_id
      t.remove :form_agency_id
      t.string :agency, :null => false
    end
  end
end
