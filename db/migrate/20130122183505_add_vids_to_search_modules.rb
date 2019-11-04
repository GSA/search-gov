class AddVidsToSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create!(:tag => 'VIDS', :display_name => 'Videos')
  end

  def down
    SearchModule.where(tag: 'VIDS').destroy_all
  end
end
