class ChangeUsesOdieResultsToResultsSource < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :results_source, :string, :default => 'bing'
    Affiliate.all.each do |affiliate|
      affiliate.update_attributes(:results_source => "odie") if affiliate.uses_odie_results == true
    end
    remove_column :affiliates, :uses_odie_results
  end

  def self.down
    add_column :affiliates, :uses_odie_results, :boolean, :default => false
    Affiliate.all.each do |affiliate|
      affiliate.update_attributes(:uses_odie_results => true) if affiliate.results_source == "bing"
    end
    remove_column :affiliates, :results_source
  end
end
