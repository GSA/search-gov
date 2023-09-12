class AddUseExtendedHeaderToAffiliates < ActiveRecord::Migration[7.0]
  def change
    add_column :affiliates, :use_extended_header, :boolean, default: true, null: false
  end
end
