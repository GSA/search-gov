module Admin::AffiliatesHelper
  def id_column(record, column)
    link_to(h(record.id), site_path(record.id))
  end

  def website_column(record, column)
    link_to_url_without_protocol record.website, target: '_blank'
  end
end
