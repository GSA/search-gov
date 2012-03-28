class AddLeftNavLabelToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :left_nav_label, :string, :limit => 20, :default => nil
  end

  def self.down
    remove_column :affiliates, :left_nav_label
  end
end
