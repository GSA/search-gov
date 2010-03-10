class SaytFilter < ActiveRecord::Base
  validates_presence_of :phrase
  validates_uniqueness_of :phrase

  after_save :apply_filter_to_sayt_suggestions

  def self.filter(results, key)
    phrases_to_filter = all
    results.reject do |rs|
      phrases_to_filter.detect do |filter|
        sanitized_term = rs[key].gsub(/<\/?[^>]*>/, '').gsub(/\xEE\x80\x80/, '').gsub(/\xEE\x80\x81/, '')
        sanitized_term =~ /(\b#{filter.phrase}\b|site:|intitle:|http:)/i
      end
    end unless results.nil?
  end

  private
  def apply_filter_to_sayt_suggestions
    SaytSuggestion.all.each do |suggestion|
      suggestion.delete if suggestion.phrase =~ /\b#{phrase}\b/i
    end
  end
end
