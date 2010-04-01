class LowercaseSaytFilters < ActiveRecord::Migration
  def self.up
    SaytFilter.all.each { |sf| sf.update_attribute(:phrase, sf.phrase.downcase) unless sf.phrase == sf.phrase.downcase }  
  end

  def self.down
  end
end
