# frozen_string_literal: true

module Scheduled
  class EmailYearlyReportsJob < ApplicationJob
    queue_as :scheduled_cron_job

    def perform(report_year = nil)
      year = report_year || Date.current.year
      User.approved_affiliate.each do |user|
        Emailer.affiliate_yearly_report(user, year.to_i).deliver if user.affiliates.present?
      rescue StandardError => e
        Rails.logger.warn "Trouble emailing yearly report to user #{user.id}: #{e}"
      end
    end
  end
end
