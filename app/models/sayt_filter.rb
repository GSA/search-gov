class SaytFilter < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase
  validates_presence_of :phrase
  validates_uniqueness_of :phrase

  after_save :apply_filter_to_sayt_suggestions

  def self.filter(inputs, key = nil)
    filters = all
    inputs.reject do |candidate|
      phrase = key == nil ? candidate : candidate[key] 
      filters.detect { |filter| phrase =~ /\b#{filter.phrase}\b/i }
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
