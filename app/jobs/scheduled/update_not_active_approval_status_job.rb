# frozen_string_literal: true

module Scheduled
  class UpdateNotActiveApprovalStatusJob < ApplicationJob
    queue_as :scheduled_cron_job

    def perform
      User.mark_inactive_as_timed_out!
    end
  end
end
