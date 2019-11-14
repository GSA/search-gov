class AddOasisImageModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'OASIS', display_name: 'OASIS image')
  end

  def down
    SearchModule.where("tag = 'OASIS'").delete_all
  end
end
