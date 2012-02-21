class SaytFilterObserver < ActiveRecord::Observer
  def after_save(sayt_filter)
    Resque.enqueue_with_priority(:high, FilterSaytSuggestions, sayt_filter.phrase)
  end
end
