class AddLocalSpellingModules < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'SPEL', display_name: 'DGSearch Spelling Suggestion')
    SearchModule.create(tag: 'LOVER', display_name: 'DGSearch Spelling Override')
  end

  def down
    SearchModule.where("tag = 'SPEL'").delete_all
    SearchModule.where("tag = 'LOVER'").delete_all
  end
end
