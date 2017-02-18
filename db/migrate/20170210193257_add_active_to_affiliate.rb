class AddActiveToAffiliate < ActiveRecord::Migration
  def change
    add_column :affiliates, :active, :boolean, default: true, null: false
  end
end
