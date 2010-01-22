class AddHostAndTldToClicks < ActiveRecord::Migration
  def self.up
    add_column :clicks, :host, :string
    add_column :clicks, :tld, :string
  end

  def self.down
    remove_column :clicks, :tld
    remove_column :clicks, :host
  end
end
