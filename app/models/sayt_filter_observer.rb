class SaytFilterObserver < ActiveRecord::Observer
  def after_save(s)
    SaytSuggestion.reapply_filters
  end

  def after_destroy(s)
    SaytSuggestion.reapply_filters
  end
end
