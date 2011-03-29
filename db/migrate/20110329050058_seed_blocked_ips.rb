class SeedBlockedIps < ActiveRecord::Migration
  def self.up
    ['41.208.172.242', '74.52.58.146' , '208.110.142.80' , '173.203.40.164', '174.132.114.162', '208.94.147.100', '165.189.65.25', '174.121.2.34'].each do |ip|
      LogfileBlockedIp.create!(:ip => ip)
    end
  end

  def self.down
    LogfileBlockedIp.delete_all
  end
end
