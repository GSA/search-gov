class LoadDeepCollectionTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.load_default_templates(['deep_collection_notification'])
  end

  def down
    EmailTemplate.where(name: 'deep_collection_notification').delete_all
  end
end
