class MakeExistingEnglishCrsRefreshable < ActiveRecord::Migration
  def self.up
    CalaisRelatedSearch.update_all("gets_refreshed=1","locale='en'")
  end

  def self.down
  end
end
