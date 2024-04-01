class AddLookingForGovernmentServicesToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :looking_for_government_services, :boolean, :default => true
  end
end
