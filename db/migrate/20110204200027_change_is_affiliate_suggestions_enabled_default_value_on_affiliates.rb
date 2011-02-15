class ChangeIsAffiliateSuggestionsEnabledDefaultValueOnAffiliates < ActiveRecord::Migration
  def self.up
    change_column_default :affiliates, :is_affiliate_suggestions_enabled, true
  end

  def self.down
    change_column_default :affiliates, :is_affiliate_suggestions_enabled, false
  end
end
