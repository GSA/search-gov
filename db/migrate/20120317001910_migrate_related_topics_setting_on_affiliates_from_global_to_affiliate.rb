class MigrateRelatedTopicsSettingOnAffiliatesFromGlobalToAffiliate < ActiveRecord::Migration
  def self.up
    update "UPDATE affiliates SET related_topics_setting = 'affiliate_enabled' WHERE related_topics_setting = 'global_enabled'"
  end

  def self.down
  end
end
