# frozen_string_literal: true

module Scheduled
  class WarnSetToNotApprovedJob < ApplicationJob
    queue_as :scheduled_cron_job

    def perform(number_of_days)
      date = number_of_days.to_i.days.ago
      UserApproval.warn_set_to_not_approved(User.approved.not_active_since(date.to_date), date.to_date)
    end
  end
end
