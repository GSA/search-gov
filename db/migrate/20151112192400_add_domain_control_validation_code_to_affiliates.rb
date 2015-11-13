class AddDomainControlValidationCodeToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :domain_control_validation_code, :string
  end
end
