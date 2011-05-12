class MedlineXmlSupport < ActiveRecord::Migration

  def self.up

    create_table :med_topics do |t|
      t.integer    :medline_tid
      t.string     :medline_title, :null => false, :limit => 255
      t.string     :medline_url, :limit => 120
      t.string     :locale, :default => 'en', :limit => 5
      t.references :lang_mapped_topic
	  t.text       :summary_html
      t.boolean    :visible, :default => true
      t.timestamps
    end

	add_index :med_topics, :medline_tid
	add_index :med_topics, :medline_title

    create_table :med_synonyms do |t|
      t.string     :medline_title, :null => false, :limit => 255
      t.references :topic, :null => false
      t.timestamps
    end

	add_index :med_synonyms, :medline_title

    create_table :med_groups do |t|
      t.integer    :medline_gid
      t.string     :medline_title, :null => false
      t.string     :medline_url, :limit => 120
      t.string     :locale, :default => 'en', :limit => 5
      t.boolean    :visible, :default => true
      t.timestamps
    end

	add_index :med_groups, :medline_gid
	add_index :med_groups, :medline_title

    create_table :med_topic_groups do |t|
      t.references :topic, :null => false
      t.references :group, :null => false
      t.timestamps
    end

    create_table :med_topic_relateds do |t|
      t.references :topic, :null => false
      t.references :related_topic, :null => false
      t.timestamps
    end

  end

  def self.down
    drop_table :med_topic_relateds
    drop_table :med_topic_groups
	remove_index :med_synonyms, :medline_title
    drop_table :med_synonyms
	remove_index :med_topics, :medline_tid
	remove_index :med_topics, :medline_title
    drop_table :med_topics
	remove_index :med_groups, :medline_gid
	remove_index :med_groups, :medline_title
    drop_table :med_groups
  end

end

