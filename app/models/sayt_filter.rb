class SaytFilter < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase
  validates_presence_of :phrase
  validates_uniqueness_of :phrase
  validate :both_not_true
  scope :accept, where(:accept => true)
  scope :deny, where(:accept => false)


  def self.filter(inputs, key = nil)
    return if inputs.nil?
    accept_filters, deny_filters = accept, deny
    whitelisted = inputs.select do |candidate|
      phrase = key == nil ? candidate : candidate[key]
      accept_filters.detect { |filter| filter.match?(phrase) }
    end
    inputs -= whitelisted
    passed = inputs.reject do |candidate|
      phrase = key == nil ? candidate : candidate[key]
      deny_filters.detect { |filter| filter.match?(phrase) }
    end
    whitelisted + passed
  end

  def match?(target_phrase)
    if filter_only_exact_phrase?
      target_phrase =~ /^#{Regexp.escape(phrase)}$/i
    elsif is_regex?
      target_phrase =~ /#{phrase}/i
    else
      target_phrase =~ /\b ?#{Regexp.escape(phrase)}\b/i
    end
  end

  def to_label
    phrase
  end

  private

  def both_not_true
    return unless is_regex? && filter_only_exact_phrase?
    errors.add(:base, 'A filter cannot be both a regular expression and an exact phrase match')
  end

  def squish_whitespace_and_downcase
    self.phrase = self.phrase.squish.downcase unless self.phrase.nil?
  end
end
