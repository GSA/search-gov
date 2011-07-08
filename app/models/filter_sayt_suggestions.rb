class FilterSaytSuggestions
  @queue = :usasearch

  def self.perform(phrase)
    sayt_filter = SaytFilter.find_by_phrase(phrase)
    SaytSuggestion.all.each { |suggestion| suggestion.delete if sayt_filter.match?(suggestion.phrase) } if sayt_filter
  end
end