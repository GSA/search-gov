class MisspellingObserver < ActiveRecord::Observer

  def after_save(misspelling)
    Resque.enqueue_with_priority(:high, SpellcheckSaytSuggestions, misspelling.wrong, misspelling.rite)
  end
end
