class InitUpdatedAtInSaytSuggestions < ActiveRecord::Migration
  def self.up
    SaytSuggestion.update_all(["updated_at = ?", Date.current])
  end

  def self.down
  end
end
