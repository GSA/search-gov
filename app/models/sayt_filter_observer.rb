class SaytFilterObserver < ActiveRecord::Observer
  def after_save(sayt_filter)
    Resque.enqueue(FilterSaytSuggestions, sayt_filter.phrase)
  end
end
