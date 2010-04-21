class AddUserAgentToClick < ActiveRecord::Migration
  def self.up
    add_column :clicks, :user_agent, :string
  end

  def self.down
    remove_column :clicks, :user_agent
  end
end
