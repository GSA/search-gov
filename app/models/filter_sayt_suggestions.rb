class FilterSaytSuggestions
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(id)
    return unless (sayt_filter = SaytFilter.find_by_id(id))
    SaytSuggestion.find_each do |suggestion|
      suggestion.destroy if sayt_filter.reject? && sayt_filter.match?(suggestion.phrase)
    end
  end
end