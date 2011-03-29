class CreateLogfileBlockedQueries < ActiveRecord::Migration
  def self.up
    create_table :logfile_blocked_queries do |t|
      t.string :query, :null => false

      t.timestamps
    end
    add_index :logfile_blocked_queries, :query, :unique => true
  end

  def self.down
    drop_table :logfile_blocked_queries
  end
end
