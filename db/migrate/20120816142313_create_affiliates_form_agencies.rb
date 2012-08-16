class CreateAffiliatesFormAgencies < ActiveRecord::Migration
  def change
    create_table :affiliates_form_agencies, :id => false do |t|
      t.references :affiliate, :null => false
      t.references :form_agency, :null => false
    end
    add_index :affiliates_form_agencies, [:affiliate_id, :form_agency_id], :unique => true, :name => 'affiliates_form_agencies_on_foreign_keys'
  end
end
