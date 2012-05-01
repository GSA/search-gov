class CreateFeaturesTable < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.string :internal_name, :null => false, :unique => true
      t.string :display_name, :null => false, :unique => true
      t.timestamps
    end
    add_index :features, :internal_name
  end

  def self.down
    drop_table :features
  end
end
