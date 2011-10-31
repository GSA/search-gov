class MisspellingObserver < ActiveRecord::Observer
  def after_save(misspelling)
    Resque.enqueue(SpellcheckSaytSuggestions, misspelling.wrong, misspelling.rite)
  end
end
