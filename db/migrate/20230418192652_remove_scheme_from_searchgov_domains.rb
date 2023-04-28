class RemoveSchemeFromSearchgovDomains < ActiveRecord::Migration[7.0]
  def change
    remove_column :searchgov_domains, :scheme, :string, default: 'http', null: false, limit: 5
  end
end
