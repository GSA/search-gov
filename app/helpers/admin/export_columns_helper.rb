module Admin::ExportColumnsHelper
  def affiliates_export_column(feature)
    feature.affiliates.collect(&:name).sort.join(',')
  end

  def agency_export_column(column)
    if column.is_a?(Affiliate)
      column.agency.friendly_name if column.agency
    else
      column.agency
    end
  end

  def created_at_export_column(column)
    export_time_column column, column.created_at
  end

  def format_export_column_header_name(column)
    column.label
  end

  def last_login_at_export_column(column)
    export_time_column column, column.last_login_at
  end

  def last_request_at_export_column(column)
    export_time_column column, column.last_request_at
  end

  def updated_at_export_column(column)
    export_time_column column, column.updated_at
  end

  def user_emails_export_column(record)
    record.user_emails.html_safe if record.is_a? Affiliate
  end

  def site_domains_export_column(record)
    if record.is_a?(Affiliate)
      record.site_domains.pluck(:domain).join(',')
    else
      record.site_domains
    end
  end

  def export_time_column(column, column_value)
    return unless column_value
    format = column.is_a?(User) ? '%Y-%m-%d' : :default
    l(column_value, format: format)
  end
end
