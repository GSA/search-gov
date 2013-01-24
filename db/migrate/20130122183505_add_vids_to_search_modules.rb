class AddVidsToSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create!(:tag => 'VIDS', :display_name => 'Videos')
  end

  def down
    SearchModule.destroy_all(:tag => 'VIDS')
  end
end
