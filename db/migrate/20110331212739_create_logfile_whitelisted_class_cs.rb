class CreateLogfileWhitelistedClassCs < ActiveRecord::Migration
  def self.up
    create_table :logfile_whitelisted_class_cs do |t|
      t.string :classc, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :logfile_whitelisted_class_cs
  end
end
