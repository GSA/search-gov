class AddAzureCompositeSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'AZCI', display_name: 'Image Results (Azure)')
    SearchModule.create(tag: 'AZCW', display_name: 'Web Results Composite (Azure)')
  end

  def down
    SearchModule.where("tag = 'AZCI'").delete_all
    SearchModule.where("tag = 'AZCW'").delete_all
  end
end
