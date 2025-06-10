class BulkAffiliateAddMailer < ApplicationMailer
  def notify(email, file_name, added_sites, failed_additions)
    @file_name = file_name
    @added_sites = added_sites
    @failed_additions = failed_additions

    subject = "Bulk Affiliate Add Results for #{file_name}"
    mail(to: email, subject: subject)
  end

  def notify_parsing_failure(email, file_name, general_errors, error_details)
    @file_name = file_name
    @general_errors = general_errors
    @error_details = error_details

    subject = "Bulk Affiliate Add Failed for #{file_name}"
    mail(to: email, subject: subject)
  end
end