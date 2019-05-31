class AddCanonicalDomainToSearchgovDomains < ActiveRecord::Migration
  def change
    add_column :searchgov_domains, :canonical_domain, :string
  end
end
