class CreateFederalRegisterAgencies < ActiveRecord::Migration
  def change
    create_table :federal_register_agencies, id: false do |t|
      t.column :id, 'int PRIMARY KEY', null: false
      t.string :name, null: false
      t.string :short_name

      t.timestamps
    end
  end
end
