class SaytFilter < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase
  validates_presence_of :phrase
  validates_uniqueness_of :phrase

  def self.filter(inputs, key = nil)
    filters = all
    inputs.reject do |candidate|
      phrase = key == nil ? candidate : candidate[key]
      filters.detect { |filter| filter.match?(phrase) }
    end unless inputs.nil?
  end

  def match?(target_phrase)
    if filter_only_exact_phrase?
      target_phrase =~ /^#{Regexp.escape(phrase)}$/i
    else
      target_phrase =~ /\b ?#{Regexp.escape(phrase)}\b/i
    end
  end

  def to_label
    phrase
  end

  private

  def squish_whitespace_and_downcase
    self.phrase = self.phrase.squish.downcase unless self.phrase.nil?
  end
end
