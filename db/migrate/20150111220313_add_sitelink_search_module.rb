class AddSitelinkSearchModule < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'DECOR', display_name: 'Decoration - Sitelink')
  end

  def down
    SearchModule.delete_all("tag = 'DECOR'")
  end
end
