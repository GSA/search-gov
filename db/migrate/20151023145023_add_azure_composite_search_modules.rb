class AddAzureCompositeSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'AZCI', display_name: 'Image Results (Azure)')
    SearchModule.create(tag: 'AZCW', display_name: 'Web Results Composite (Azure)')
  end

  def down
    SearchModule.delete_all("tag = 'AZCI'")
    SearchModule.delete_all("tag = 'AZCW'")
  end
end
