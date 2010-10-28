class DropLogFile < ActiveRecord::Migration
  def self.up
    drop_table :log_files    
  end

  def self.down
    create_table :log_files do |t|
      t.string :name, :null => false
      t.timestamps
    end
    add_index :log_files, :name, :unique => true
  end
end
