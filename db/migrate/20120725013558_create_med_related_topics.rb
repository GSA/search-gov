class CreateMedRelatedTopics < ActiveRecord::Migration
  def up
    create_table :med_related_topics do |t|
      t.belongs_to :med_topic, :null => false
      t.integer :related_medline_tid, :null => false
      t.string :title, :null => false
      t.string :url, :null => false

      t.timestamps
    end
    add_index :med_related_topics, :med_topic_id
  end

  def down
    drop_table :med_related_topics
  end
end
