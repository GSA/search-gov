class SaytFilterObserver < ActiveRecord::Observer
  def after_save(s)
    Resque.enqueue_with_priority(:low, ApplySaytFilters)
  end

  def after_destroy(s)
    Resque.enqueue_with_priority(:low, ApplySaytFilters)
  end
end
