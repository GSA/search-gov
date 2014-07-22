module Admin::ExportColumnsHelper
  def affiliates_export_column(feature)
    feature.affiliates.collect(&:name).sort.join(',')
  end

  def format_export_column_header_name(column)
    column.label
  end

  def user_emails_export_column(record)
    record.user_emails.html_safe if record.is_a? Affiliate
  end
end
