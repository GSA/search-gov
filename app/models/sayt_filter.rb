class SaytFilter < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase
  validates_presence_of :phrase
  validates_uniqueness_of :phrase

  after_save :apply_filter_to_sayt_suggestions

  def self.filter(inputs, key)
    filters = all
    inputs.reject do |candidate|
      rejected = filters.detect { |filter| candidate[key] =~ /\b#{filter.phrase}\b/i }
      rejected = candidate[key] =~ /(site:|intitle:|http:)/i unless rejected
      rejected
    end unless inputs.nil?
  end

  private
  def apply_filter_to_sayt_suggestions
    SaytSuggestion.all.each do |suggestion|
      suggestion.delete if suggestion.phrase =~ /\b#{phrase}\b/i
    end
  end

  def squish_whitespace_and_downcase
    self.phrase = self.phrase.squish.downcase unless self.phrase.nil?
  end
end
