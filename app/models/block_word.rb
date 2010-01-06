class BlockWord < ActiveRecord::Base
  validates_presence_of :word
  validates_uniqueness_of :word

  def self.filter(results, key)
    results.reject { |rs| all.detect { |bw| rs[key] =~ /#{bw.word}\b/i } } unless results.nil?
  end
end
