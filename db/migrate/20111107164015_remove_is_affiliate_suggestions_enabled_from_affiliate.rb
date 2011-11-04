class RemoveIsAffiliateSuggestionsEnabledFromAffiliate < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :is_affiliate_suggestions_enabled
  end

  def self.down
    add_column :affiliates, :is_affiliate_suggestions_enabled, :boolean
  end
end
