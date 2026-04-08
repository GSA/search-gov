# frozen_string_literal: true

class BulkAffiliateDeactivateMailer < ApplicationMailer
  def notify(requesting_user_email, file_name, successful_ids, failed_updates)
    @file_name = file_name
    @successful_count = successful_ids.count
    @failed_count = failed_updates.count
    @failed_updates = failed_updates

    mail(
      to: requesting_user_email,
      subject: "Bulk Affiliate Deactivation Results for #{file_name}"
    )
  end

  def notify_parsing_failure(requesting_user_email, file_name, general_errors, error_details)
    @file_name = file_name
    @general_errors = general_errors
    @error_details = error_details

    mail(
      to: requesting_user_email,
      subject: "Failed to Process Bulk Affiliate Deactivation File: #{file_name}"
    )
  end
end