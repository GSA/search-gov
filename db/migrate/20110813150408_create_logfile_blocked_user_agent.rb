class CreateLogfileBlockedUserAgent < ActiveRecord::Migration
  def self.up
    create_table :logfile_blocked_user_agents do |t|
      t.string :agent, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :logfile_blocked_user_agents
  end
end