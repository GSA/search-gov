class CreateLogFileTable < ActiveRecord::Migration
  def self.up
    create_table :log_files do |t|
      t.string :name, :null => false
      t.timestamps
    end
    add_index :log_files, :name, :unique => true
  end

  def self.down
    drop_table :log_files
  end
end
