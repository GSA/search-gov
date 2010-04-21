class AddClickIpToClick < ActiveRecord::Migration
  def self.up
    add_column :clicks, :click_ip, :string
  end

  def self.down
    remove_column :clicks, :click_ip
  end
end
