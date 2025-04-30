class BulkAffiliateDeleteMailer < ApplicationMailer
  def notify(email, file_name, deleted_ids, failed_deletions)
    @email = email
    @file_name = file_name
    @deleted_ids = deleted_ids
    @failed_deletions = failed_deletions

    subject = "Bulk Affiliate Delete Results for #{file_name}"
    mail(to: @email, subject: subject)
  end

  def notify_parsing_failure(email, file_name, general_errors, error_details)
    @email = email
    @file_name = file_name
    @general_errors = general_errors
    @error_details = error_details

    subject = "Bulk Affiliate Delete Failed for #{file_name}"
    mail(to: @email, subject: subject)
  end
end
