class CreateLogfileBlockedClassCs < ActiveRecord::Migration
  def self.up
    create_table :logfile_blocked_class_cs do |t|
      t.string :classc, :null => false

      t.timestamps
    end
    add_index :logfile_blocked_class_cs, :classc, :unique => true
  end

  def self.down
    drop_table :logfile_blocked_class_cs
  end
end
