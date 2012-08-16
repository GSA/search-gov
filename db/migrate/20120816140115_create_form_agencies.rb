class CreateFormAgencies < ActiveRecord::Migration
  def change
    create_table :form_agencies do |t|
      t.string :name, :null => false
      t.string :locale, :null => false
      t.string :display_name, :null => false

      t.timestamps
    end
  end
end
