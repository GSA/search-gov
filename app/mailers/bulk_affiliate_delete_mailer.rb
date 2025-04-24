class BulkAffiliateDeleteMailer < ApplicationMailer
  def notify(email, file_name, deleted_ids, failed_deletions)
    @email = email
    @file_name = file_name
    @deleted_ids = deleted_ids
    @failed_deletions = failed_deletions

    subject = "Bulk Affiliate Delete Results for #{file_name}"
    mail(to: @email, subject: subject)
  end
end
