class SquishSaytFilters < ActiveRecord::Migration
  def self.up
    SaytFilter.all.each { |sf| sf.update_attribute(:phrase, sf.phrase.squish) unless sf.phrase == sf.phrase.squish }
  end

  def self.down
  end
end
