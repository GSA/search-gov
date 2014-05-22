module Admin::ExportColumnsHelper
  def user_emails_export_column(record)
    record.user_emails.html_safe if record.is_a? Affiliate
  end
end
