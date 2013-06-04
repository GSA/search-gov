class DropMedTopicRelateds < ActiveRecord::Migration
  def up
    drop_table :med_topic_relateds
  end

  def down
    create_table "med_topic_relateds", :force => true do |t|
      t.integer  "topic_id",         :null => false
      t.integer  "related_topic_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
