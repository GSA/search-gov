module Admin::AffiliatesHelper
  def id_column(record, column)
    link_to(h(record.id), affiliate_path(record.id))
  end
end