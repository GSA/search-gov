class WatcherObserver < ActiveRecord::Observer

  def after_save(watcher)
    puts "9"*80
    puts watcher.body

  end
end
