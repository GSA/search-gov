class TrimSaytFilters < ActiveRecord::Migration
  def self.up
    SaytFilter.all.each { |sf| sf.update_attribute(:phrase, sf.phrase.strip) unless sf.phrase == sf.phrase.strip }
  end

  def self.down
  end
end
