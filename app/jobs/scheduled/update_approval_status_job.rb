# frozen_string_literal: true

module Scheduled
  class UpdateApprovalStatusJob < ApplicationJob
    queue_as :scheduled_cron_job

    def perform
      UserApproval.set_to_not_approved(
        User.approved_affiliate.select { |user| user.affiliates.empty? },
        'is no longer associated with any sites',
        'siteless'
      )
    end
  end
end
