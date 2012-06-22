class FilterSaytSuggestions
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(phrase)
    sayt_filter = SaytFilter.find_by_phrase(phrase)
    SaytSuggestion.find_each { |suggestion| suggestion.destroy if sayt_filter.match?(suggestion.phrase) } if sayt_filter
  end
end