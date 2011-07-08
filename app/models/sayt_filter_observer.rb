class SaytFilterObserver < ActiveRecord::Observer
  @queue = :usasearch

  def after_save(sayt_filter)
    Resque.enqueue(FilterSaytSuggestions, sayt_filter.phrase)
  end
end
