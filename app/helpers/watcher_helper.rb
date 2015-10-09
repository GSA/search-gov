module WatcherHelper
  def watcher_partial_for(watcher)
    "/sites/watchers/#{watcher.class.to_s.underscore}"
  end
end
