class AddTwitterToSearchModules < ActiveRecord::Migration
  def up
    SearchModule.create!(:tag => 'TWEET', :display_name => 'Tweet')
  end

  def down
    SearchModule.where(tag: 'TWEET').destroy_all
  end
end
