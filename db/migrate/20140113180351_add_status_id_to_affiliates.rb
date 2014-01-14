class AddStatusIdToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :status_id, :integer, default: 2, null: false
  end
end
