class ApplyFiltersToSaytSuggestion
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform(id)
    return unless (sayt_suggestion = SaytSuggestion.find_by_id(id))
    if SaytFilter.filter([sayt_suggestion.phrase]).empty?
      sayt_suggestion.destroy
    elsif SaytFilter.filters_match?(SaytFilter.accept, sayt_suggestion.phrase)
      sayt_suggestion.update_attribute(:is_whitelisted, true)
    end
  end
end
