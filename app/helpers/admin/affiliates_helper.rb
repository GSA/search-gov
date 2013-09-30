module Admin::AffiliatesHelper
  def id_column(record, column)
    link_to(h(record.id), site_path(record.id))
  end
end
