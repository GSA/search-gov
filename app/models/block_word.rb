class BlockWord < ActiveRecord::Base
  validates_presence_of :word
  validates_uniqueness_of :word

  def self.filter(results, key, number_of_records)
    block_words = all
    records = results.reject { |rs| block_words.detect { |bw| rs[key].gsub(/<\/?[^>]*>/, '') =~ /#{bw.word}\b/i } } unless results.nil?
    records[0, number_of_records] unless records.nil?
  end
end
