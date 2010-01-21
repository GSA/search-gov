class BlockWord < ActiveRecord::Base
  validates_presence_of :word
  validates_uniqueness_of :word

  def self.filter(results, key)
    block_words = all
    results.reject { |rs| block_words.detect { |bw| rs[key].gsub(/<\/?[^>]*>/, '') =~ /#{bw.word}\b/i } } unless results.nil?
  end
end
