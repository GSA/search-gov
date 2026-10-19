# frozen_string_literal: true

module Scheduled
  class UpdateNotActiveApprovalStatusJob < ApplicationJob
    queue_as :scheduled_cron_job

    def perform
      Rails.logger.info('UpdateNotActiveApprovalStatusJob started')
      updated_user_count = User.mark_inactive_as_timed_out!
      Rails.logger.info("UpdateNotActiveApprovalStatusJob completed: timed out #{updated_user_count} user(s)")
    end
  end
end
