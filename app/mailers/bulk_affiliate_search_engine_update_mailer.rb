# frozen_string_literal: true

class BulkAffiliateSearchEngineUpdateMailer < ApplicationMailer
  def notify(requesting_user_email, file_name, successful_updates, failed_updates)
    @file_name = file_name
    @successful_updates = successful_updates
    @failed_updates = failed_updates

    mail(
      to: requesting_user_email,
      subject: "Bulk Affiliate Search Engine Update Results for #{file_name}"
    )
  end

  def notify_parsing_failure(requesting_user_email, file_name, general_errors, error_details)
    @file_name = file_name
    @general_errors = general_errors
    @error_details = error_details

    mail(
      to: requesting_user_email,
      subject: "Bulk Affiliate Search Engine Update - File Parsing Failed for #{file_name}"
    )
  end
end