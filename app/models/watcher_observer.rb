class WatcherObserver < ActiveRecord::Observer

  def after_save(watcher)
    puts watcher.body
  end
end
