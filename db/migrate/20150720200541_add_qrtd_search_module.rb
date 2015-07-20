class AddQrtdSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'QRTD', display_name: 'Routed Query')
  end

  def down
    SearchModule.delete_all("tag = 'QRTD'")
  end
end
