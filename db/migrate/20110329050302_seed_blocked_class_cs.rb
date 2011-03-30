class SeedBlockedClassCs < ActiveRecord::Migration
  def self.up
    ['192.107.175', '95.168.191', '192.168.100' , '192.168.110' , '95.168.178', '95.168.177', '208.51.185', '85.10.224', '207.170.201'].each do |classc|
      LogfileBlockedClassC.create!(:classc => classc)
    end
  end

  def self.down
    LogfileBlockedClassC.delete_all
  end
end
