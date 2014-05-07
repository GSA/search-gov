class AddLocalSpellingModules < ActiveRecord::Migration
  def up
    SearchModule.create(tag: 'SPEL', display_name: 'DGSearch Spelling Suggestion')
    SearchModule.create(tag: 'LOVER', display_name: 'DGSearch Spelling Override')
  end

  def down
    SearchModule.delete_all("tag = 'SPEL'")
    SearchModule.delete_all("tag = 'LOVER'")
  end
end
