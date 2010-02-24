class BlockWord < ActiveRecord::Base
  validates_presence_of :word
  validates_uniqueness_of :word

  def self.filter(results, key, number_of_records)
    block_words = all
    records = results.reject do |rs|
      block_words.detect do |bw|
        sanitized_term = rs[key].gsub(/<\/?[^>]*>/, '').gsub(/\xEE\x80\x80/, '').gsub(/\xEE\x80\x81/, '')
        sanitized_term =~ /\b#{bw.word}\b/i
      end
    end unless results.nil?
    records[0, number_of_records] unless records.nil?
  end
end
