class SynchronizedObjectHolder

  def initialize(&block)
    define_singleton_method :get_object, block
    @object = get_object
    @changed = false
    @mutex = Mutex.new
  end

  def object_changed?
    refresh_object
    @changed
  end

  def get_object_and_reset_changed
    @mutex.synchronize do
      @changed = false
      @object
    end
  end

  private

  def refresh_object
    @mutex.synchronize do
      refreshed_object = get_object
      if @object != refreshed_object
        @object = refreshed_object
        @changed = true
      end
    end
  end
end
