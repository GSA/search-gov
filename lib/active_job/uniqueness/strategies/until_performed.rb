# frozen_string_literal: true

# Custom strategy used by the activejob-uniqueness gem.
# Ensures jobs are unique from the time enqueued until performed,
# even if errors are raised (or until lock expires).
class UntilPerformed < ActiveJob::Uniqueness::Strategies::Base
  include LockingOnEnqueue

  def around_perform(block)
    block.call
  ensure
    unlock(resource: lock_key)
  end
end
