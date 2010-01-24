class SetLimitsOnClicksFields < ActiveRecord::Migration
  def self.up
    change_column :clicks, :source, :string, :limit => 100
    change_column :clicks, :affiliate, :string, :limit => 50
    change_column :clicks, :project, :string, :limit => 50
    change_column :clicks, :host, :string, :limit => 100
    change_column :clicks, :tld, :string, :limit => 10
  end

  def self.down
    change_column :clicks, :source, :string, :limit => 255
    change_column :clicks, :affiliate, :string, :limit => 255
    change_column :clicks, :project, :string, :limit => 255
    change_column :clicks, :host, :string, :limit => 255
    change_column :clicks, :tld, :string, :limit => 255
  end
end
