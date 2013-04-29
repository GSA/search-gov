class LoadDeepCollectionTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(['deep_collection_notification'])
  end

  def down
    EmailTemplate.delete_all(:name => 'deep_collection_notification')
  end
end
