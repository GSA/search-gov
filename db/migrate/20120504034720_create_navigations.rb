class CreateNavigations < ActiveRecord::Migration
  def self.up
    create_table :navigations do |t|
      t.belongs_to :affiliate, :null => false
      t.belongs_to :navigable, :polymorphic => true, :null => false
      t.integer :position, :null => false, :default => 100
      t.boolean :is_active, :null => false, :default => false

      t.timestamps
    end
    add_index :navigations, :affiliate_id
  end

  def self.down
    drop_table :navigations
  end
end
