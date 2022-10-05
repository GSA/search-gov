class ApplySaytFilters
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform
    SaytSuggestion.select(:id).find_each do |suggestion|
      Resque.enqueue_with_priority(:high, ApplyFiltersToSaytSuggestion, suggestion.id)
    end
  end
end
