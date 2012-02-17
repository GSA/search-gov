class SeedStagedUsesOneSerpOnAffiliates < ActiveRecord::Migration
  def self.up
    update "UPDATE affiliates SET staged_uses_one_serp = uses_one_serp"
  end

  def self.down
  end
end
