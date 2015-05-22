class AddI14yModules < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'ISPEL', display_name: 'I14y spelling override')
    SearchModule.create(tag: 'I14Y', display_name: 'I14y document')
  end

  def down
    SearchModule.delete_all("tag = 'I14Y'")
    SearchModule.delete_all("tag = 'ISPEL'")
  end
end
