class RenameBoostedSiteToBoostedContent < ActiveRecord::Migration
  def self.up
    rename_table :boosted_sites, :boosted_contents
  end

  def self.down
    rename_table :boosted_contents, :boosted_sites
  end
end
