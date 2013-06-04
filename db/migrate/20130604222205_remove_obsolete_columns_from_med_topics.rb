class RemoveObsoleteColumnsFromMedTopics < ActiveRecord::Migration
  def up
    remove_column :med_topics, :lang_mapped_topic_id
    remove_column :med_topics, :visible
    remove_column :med_topics, :mesh_titles
  end

  def down
    add_column :med_topics, :mesh_titles, :string, default: ''
    add_column :med_topics, :visible, :boolean, default: true
    add_column :med_topics, :lang_mapped_topic_id, :integer
  end
end
