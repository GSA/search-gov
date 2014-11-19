class AddAzureWebResultsOnlySearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'AWEB', display_name: 'Web Results Only (Azure)')
  end

  def down
    SearchModule.delete_all("tag = 'AWEB'")
  end
end
