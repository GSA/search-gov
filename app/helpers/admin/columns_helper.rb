module Admin::ColumnsHelper
  def affiliates_export_column(feature)
    feature.affiliates.collect(&:name).sort.join(',')
  end

  def id_column(record, column)
    if record.is_a?(Affiliate)
      link_to record.id, site_path(record.id), target: '_blank'
    else
      record[column.name]
    end
  end

  def user_emails_column(record, column)
    if record.is_a?(Affiliate)
      record.users.map(&:to_label).join(',')
    end
  end

  def name_column(record, column)
    if record.is_a? RssFeed
      link_to record.name, site_rss_feed_path(record.owner, record.id), target: '_blank'
    else
      record[column.name]
    end
  end

  def owner_column(record, column)
    link_to(record.owner.display_name, site_path(record.owner.id), target: '_blank') if record.owner.is_a?(Affiliate)
  end

  def url_column(record, column)
    link_to_url_without_protocol record.url, target: '_blank'
  end

  def website_column(record, column)
    link_to_url_without_protocol record.website, target: '_blank'
  end
end
