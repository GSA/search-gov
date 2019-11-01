class AddAzureWebResultsOnlySearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'AWEB', display_name: 'Web Results Only (Azure)')
  end

  def down
    SearchModule.where("tag = 'AWEB'").delete_all
  end
end
