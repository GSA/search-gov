class MisspellingObserver < ActiveRecord::Observer
  @queue = :usasearch

  def after_save(misspelling)
    Resque.enqueue(SpellcheckSaytSuggestions, misspelling.wrong, misspelling.rite)
  end
end
