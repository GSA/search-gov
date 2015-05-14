class AddI14yFlagToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :gets_i14y_results, :boolean, null: false, default: false
  end
end
