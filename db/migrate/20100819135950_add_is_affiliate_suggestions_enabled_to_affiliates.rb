class AddIsAffiliateSuggestionsEnabledToAffiliates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :is_affiliate_suggestions_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :affiliates, :is_affiliate_suggestions_enabled
  end
end
