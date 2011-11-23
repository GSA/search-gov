class RemoveSpotlights < ActiveRecord::Migration
  def self.up
    drop_table :spotlight_keywords
    drop_table :spotlights
  end

  def self.down
    create_table :spotlights do |t|
      t.string :title, :null=> false
      t.string :notes
      t.text :html, :null=> false
      t.boolean :is_active, :null=> false, :default => true
      t.integer :affiliate_id

      t.timestamps
    end
    create_table :spotlight_keywords do |t|
      t.references :spotlight, :null => false
      t.string :name, :null=> false

      t.timestamps
    end
    add_index :spotlight_keywords, :spotlight_id
  end
end
