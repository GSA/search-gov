class CreateSpotlights < ActiveRecord::Migration
  def self.up
    create_table :spotlights do |t|
      t.string :title, :null=> false
      t.string :notes
      t.text :html, :null=> false
      t.boolean :is_active, :null=> false, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :spotlights
  end
end
