class RemoveDeprecatedTweetModuleFromSearchModules < ActiveRecord::Migration[7.1]
  def up
    SearchModule.where(tag: "TWEET").delete_all
  end

  def down
    SearchModule.create(tag: 'TWEET', display_name: 'Tweets')
  end
end
