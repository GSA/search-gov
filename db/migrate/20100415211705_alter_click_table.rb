class AlterClickTable < ActiveRecord::Migration
  def self.up
    remove_column :clicks, :created_at
    remove_column :clicks, :updated_at
    remove_column :clicks, :project
    remove_column :clicks, :tld
    remove_column :clicks, :host
    remove_column :clicks, :source
    add_column :clicks, :clicked_at, :datetime
    add_column :clicks, :results_source, :string
  end

  def self.down
    remove_column :clicks, :clicked_at
    remove_column :clicks, :results_source
    add_column :clicks, :created_at, :datetime
    add_column :clicks, :updated_at, :datetime
    add_column :clicks, :project, :string
    add_column :clicks, :tld, :string
    add_column :clicks, :host, :string
    add_column :clicks, :source, :string
  end
end
