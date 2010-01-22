class AddIndexToTldClicks < ActiveRecord::Migration
  def self.up
    add_index :clicks, :tld, :unique => false
  end

  def self.down
    remove_index :clicks, :tld
  end
end
