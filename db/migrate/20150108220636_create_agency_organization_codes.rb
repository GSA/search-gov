class CreateAgencyOrganizationCodes < ActiveRecord::Migration
  def self.up
    create_table :agency_organization_codes do |t|
      t.references :agency
      t.string :organization_code
      t.timestamps
    end
    Agency.all.each do |agency|
      AgencyOrganizationCode.create(:agency => agency, :organization_code => agency.organization_code) if agency.organization_code.present?
    end
    remove_column :agencies, :organization_code
  end

  def self.down
    add_column :agencies, :organization_code, :string
    AgencyOrganizationCode.all.each do |agency_organization_code|
      agency_organization_code.agency.organization_code = agency_organization_code.organization_code
      agency_organization_code.agency.save
    end
    drop_table :agency_organization_codes
  end
end
