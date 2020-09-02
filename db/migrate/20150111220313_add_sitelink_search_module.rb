class AddSitelinkSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'DECOR', display_name: 'Decoration - Sitelink')
  end

  def down
    SearchModule.where("tag = 'DECOR'").delete_all
  end
end
