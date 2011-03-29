class CreateLogfileBlockedRegexps < ActiveRecord::Migration
  def self.up
    create_table :logfile_blocked_regexps do |t|
      t.string :regexp, :null => false

      t.timestamps
    end
    add_index :logfile_blocked_regexps, :regexp, :unique => true   
  end

  def self.down
    drop_table :logfile_blocked_regexps
  end
end
