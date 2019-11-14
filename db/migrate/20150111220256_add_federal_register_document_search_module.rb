class AddFederalRegisterDocumentSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'FRDOC', display_name: 'Federal Register Document')
  end

  def down
    SearchModule.where("tag = 'FRDOC'").delete_all
  end
end
