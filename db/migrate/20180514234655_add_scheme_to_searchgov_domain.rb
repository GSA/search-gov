class AddSchemeToSearchgovDomain < ActiveRecord::Migration
  def change
    add_column :searchgov_domains, :scheme, :string, default: 'http', null: false, limit: 5
  end
end
