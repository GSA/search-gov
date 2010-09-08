class ZeroOutSaytSuggestionRankings < ActiveRecord::Migration
  def self.up
    SaytSuggestion.update_all({:popularity=>0}, ["updated_at < ?", Date.yesterday])
  end

  def self.down
  end
end
