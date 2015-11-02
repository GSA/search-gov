module WatcherHelper
  def watcher_partial_for(watcher)
    "/sites/watchers/#{watcher.class.to_s.underscore}"
  end

  def intro_watcher_partial_for(watcher)
    "/sites/watchers/intro_#{watcher.class.to_s.underscore}"
  end
end
