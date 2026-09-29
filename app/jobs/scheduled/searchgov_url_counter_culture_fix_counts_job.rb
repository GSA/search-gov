# frozen_string_literal: true

module Scheduled
  class SearchgovUrlCounterCultureFixCountsJob < ApplicationJob
    queue_as :scheduled_cron_job

    def perform
      SearchgovUrl.counter_culture_fix_counts
    end
  end
end
