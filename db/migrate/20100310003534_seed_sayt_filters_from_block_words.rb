class SeedSaytFiltersFromBlockWords < ActiveRecord::Migration
  def self.up
    BlockWord.all.each {|bw| SaytFilter.create(:phrase => bw.word) }
  end

  def self.down
    SaytFilter.delete_all
  end
end
