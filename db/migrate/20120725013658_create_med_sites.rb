class CreateMedSites < ActiveRecord::Migration
  def up
    create_table :med_sites do |t|
      t.belongs_to :med_topic, :null => false
      t.string :title, :null => false
      t.string :url, :null => false

      t.timestamps
    end
    add_index :med_sites, :med_topic_id
  end

  def down
    drop_table :med_sites
  end
end
