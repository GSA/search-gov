module Admin::AdminHelper
  def affiliates_export_column(feature)
    feature.affiliates.collect(&:name).sort.join(',')
  end
end