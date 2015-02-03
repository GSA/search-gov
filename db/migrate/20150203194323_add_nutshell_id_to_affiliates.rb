class AddNutshellIdToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :nutshell_id, :integer
  end
end
