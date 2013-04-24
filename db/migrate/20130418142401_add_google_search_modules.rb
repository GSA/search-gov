class AddGoogleSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create!(tag: 'GIMAG', display_name: 'Google Image Results')
    SearchModule.create!(tag: 'GWEB', display_name: 'Google Web Results')
  end

  def down
    SearchModule.find_by_tag('GIMAG').destroy
    SearchModule.find_by_tag('GWEB').destroy
  end
end
