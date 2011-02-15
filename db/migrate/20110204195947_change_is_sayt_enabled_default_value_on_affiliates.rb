class ChangeIsSaytEnabledDefaultValueOnAffiliates < ActiveRecord::Migration
  def self.up
    change_column_default :affiliates, :is_sayt_enabled, true
  end

  def self.down
    change_column_default :affiliates, :is_sayt_enabled, false
  end
end
