module Resque
  def self.enqueue(task, *args)
    task.perform(*args)
  end
end