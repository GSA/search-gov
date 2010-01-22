class AddIndexToHostClicks < ActiveRecord::Migration
  def self.up
    add_index :clicks, :host, :unique => false
  end

  def self.down
    remove_index :clicks, :host
  end
end
