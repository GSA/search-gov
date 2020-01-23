# frozen_string_literal: true

class WatcherObserver < ActiveRecord::Observer
  def after_save(watcher)
    ES::ELK.client_reader.xpack.watcher.put_watch(id: watcher.id, body: watcher.body)
  end

  def after_destroy(watcher)
    ES::ELK.client_reader.xpack.watcher.delete_watch(id: watcher.id)
  end
end
