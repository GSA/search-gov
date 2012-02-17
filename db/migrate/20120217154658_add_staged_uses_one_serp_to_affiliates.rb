class AddStagedUsesOneSerpToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :staged_uses_one_serp, :boolean
  end

  def self.down
    remove_column :affiliates, :staged_uses_one_serp
  end
end
