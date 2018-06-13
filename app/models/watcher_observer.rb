class WatcherObserver < ActiveRecord::Observer

  def after_save(watcher)
    ES::ELK.client_reader.watcher.put_watch id: watcher.id, body: watcher.body
  end

  def after_destroy(watcher)
    ES::ELK.client_reader.watcher.delete_watch id: watcher.id, force: true
  end
end
