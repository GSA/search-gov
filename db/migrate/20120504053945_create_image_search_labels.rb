class CreateImageSearchLabels < ActiveRecord::Migration
  def self.up
    create_table :image_search_labels do |t|
      t.belongs_to :affiliate, :null => false
      t.string :name, :null => false

      t.timestamps
    end
    add_index :image_search_labels, :affiliate_id, :unique => true
  end

  def self.down
    drop_table :image_search_labels
  end
end
