class RemoveIdentifierDomainNameFromAffiliates < ActiveRecord::Migration[7.1]
  def change
    remove_column :affiliates, :identifier_domain_name, :string
  end
end
