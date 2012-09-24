class AddTwitterToSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create!(:tag => 'TWEET', :display_name => 'Tweet')
  end

  def down
    SearchModule.destroy_all(:tag => 'TWEET')
  end
end
