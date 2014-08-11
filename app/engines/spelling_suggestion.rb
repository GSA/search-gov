class SpellingSuggestion
  def initialize(query, did_you_mean_suggestion)
    @query = query
    @did_you_mean_suggestion = did_you_mean_suggestion
  end

  def cleaned
    cleaned_suggestion = normalize(@did_you_mean_suggestion)
    cleaned_query = normalize(@query)
    same_or_overridden?(cleaned_suggestion, cleaned_query) ? nil : cleaned_suggestion
  end

  private

  def same_or_overridden?(cleaned_suggestion, cleaned_query)
    FuzzyMatcher.new(cleaned_suggestion, cleaned_query).matches?
  end

  def normalize(str)
    stripped_str = str.gsub(/(\uE000|\uE001|[()|+])/, '')
    remaining_tokens = stripped_str.split.reject do |token|
      token.starts_with?('language:', 'site:', '-site:', 'scopeid:') || %w(OR AND NOT).include?(token.upcase)
    end
    remaining_tokens.join(' ').gsub('-', '').downcase
  end
end