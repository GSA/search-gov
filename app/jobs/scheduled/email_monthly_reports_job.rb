# frozen_string_literal: true

module Scheduled
  class EmailMonthlyReportsJob < ApplicationJob
    queue_as :scheduled_cron_job

    def perform(report_year_month = nil)
      report_date = report_year_month.blank? ? Date.yesterday : Date.parse("#{report_year_month}-01")
      User.approved_affiliate.each do |user|
        Emailer.affiliate_monthly_report(user, report_date).deliver if user.affiliates.present?
      rescue StandardError => e
        Rails.logger.warn "Trouble emailing monthly report to user #{user.id}: #{e}"
      end
    end
  end
end
