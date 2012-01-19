class AddUsesOdieResultsToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :uses_odie_results, :boolean, :default => false
  end

  def self.down
    remove_column :affiliates, :uses_odie_results
  end
end
