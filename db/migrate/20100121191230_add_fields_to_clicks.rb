class AddFieldsToClicks < ActiveRecord::Migration
  def self.up
    add_column :clicks, :source, :string
    add_column :clicks, :affiliate, :string
    add_column :clicks, :project, :string
  end

  def self.down
    remove_column :clicks, :project
    remove_column :clicks, :affiliate
    remove_column :clicks, :source
  end
end
