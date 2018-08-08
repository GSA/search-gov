require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'active_scheduler'

namespace :resque do
  task :setup_schedule => [:environment] do
    require 'resque'
    require 'resque-scheduler'

    # If you want to be able to dynamically change the schedule,
    # uncomment this line.  A dynamic schedule can be updated via the
    # Resque::Scheduler.set_schedule (and remove_schedule) methods.
    # When dynamic is set to true, the scheduler process looks for
    # schedule changes and applies them on the fly.
    # Note: This feature is only available in >=2.0.0.
    # Resque::Scheduler.dynamic = true

    # The schedule doesn't need to be stored in a YAML, it just needs to
    # be a hash.  YAML is usually the easiest.
    yaml_schedule = Rails.application.config_for('resque_schedule')
    Resque.schedule = ActiveScheduler::ResqueWrapper.wrap yaml_schedule
  end

  task :scheduler => :setup_schedule
end
