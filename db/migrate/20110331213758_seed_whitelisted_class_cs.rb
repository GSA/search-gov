class SeedWhitelistedClassCs < ActiveRecord::Migration
  def self.up
    LogfileWhitelistedClassC.create!(:classc => "192.107.175")
    LogfileBlockedClassC.where('classc = "192.107.175"').delete_all
  end

  def self.down
    LogfileBlockedClassC.create!(:classc => "192.107.175")
    LogfileWhitelistedClassC.delete_all
  end
end
