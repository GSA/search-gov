class AddI14yModules < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'ISPEL', display_name: 'I14y spelling override')
    SearchModule.create(tag: 'I14Y', display_name: 'I14y document')
  end

  def down
    SearchModule.where("tag = 'I14Y'").delete_all
    SearchModule.where("tag = 'ISPEL'").delete_all
  end
end
