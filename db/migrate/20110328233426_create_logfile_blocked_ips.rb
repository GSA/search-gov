class CreateLogfileBlockedIps < ActiveRecord::Migration
  def self.up
    create_table :logfile_blocked_ips do |t|
      t.string :ip, :null => false

      t.timestamps
    end
    add_index :logfile_blocked_ips, :ip, :unique => true
  end

  def self.down
    drop_table :logfile_blocked_ips
  end
end
