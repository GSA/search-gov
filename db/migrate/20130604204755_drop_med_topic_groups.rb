class DropMedTopicGroups < ActiveRecord::Migration
  def up
    drop_table :med_topic_groups
  end

  def down
    create_table "med_topic_groups", :force => true do |t|
      t.integer  "topic_id",   :null => false
      t.integer  "group_id",   :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
