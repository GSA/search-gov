class AddOasisSpelingModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'OSPEL', display_name: 'OASIS spelling suggestion')
  end

  def down
    SearchModule.where("tag = 'OSPEL'").delete_all
  end
end
