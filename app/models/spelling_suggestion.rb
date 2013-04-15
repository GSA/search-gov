class SpellingSuggestion
  def initialize(query, did_you_mean_suggestion)
    @query = query.downcase
    @did_you_mean_suggestion = did_you_mean_suggestion.downcase
  end

  def cleaned
    cleaned_suggestion = strip_extra_chars_from(@did_you_mean_suggestion)
    cleaned_query = strip_extra_chars_from(@query)
    same_or_overridden?(cleaned_suggestion, cleaned_query) ? nil : cleaned_suggestion
  end

  private

  def same_or_overridden?(cleaned_suggestion, cleaned_query)
    cleaned_suggestion == cleaned_query || (cleaned_suggestion.present? && cleaned_suggestion.starts_with?('+'))
  end

  def strip_extra_chars_from(did_you_mean_suggestion)
    if did_you_mean_suggestion.present?
      remaining_tokens = did_you_mean_suggestion.split(/ \(scopeid/).first.gsub(/\(-site:[^)]*\)/, '').gsub(/\(site:[^)]*\)/, '').
        gsub(/[()]/, '').gsub(/(\uE000|\uE001)/, '').gsub('-', '').split
      remaining_tokens.reject { |token| token.starts_with?('language:', 'site:') }.join(' ')
    end
  end

end