class SeedWhitelistedClassCs < ActiveRecord::Migration
  def self.up
    LogfileWhitelistedClassC.create!(:classc => "192.107.175")
    LogfileBlockedClassC.delete_all("classc = '192.107.175'")
  end

  def self.down
    LogfileBlockedClassC.create!(:classc => "192.107.175")
    LogfileWhitelistedClassC.delete_all
  end
end
