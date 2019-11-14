class AddQrtdSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'QRTD', display_name: 'Routed Query')
  end

  def down
    SearchModule.where("tag = 'QRTD'").delete_all
  end
end
