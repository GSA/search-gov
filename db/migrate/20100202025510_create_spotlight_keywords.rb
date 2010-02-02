class CreateSpotlightKeywords < ActiveRecord::Migration
  def self.up
    create_table :spotlight_keywords do |t|
      t.references :spotlight, :null => false
      t.string :name, :null=> false

      t.timestamps
    end
    add_index :spotlight_keywords, :spotlight_id    
  end

  def self.down
    drop_table :spotlight_keywords
  end
end
