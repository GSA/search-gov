class Admin::CseAnnotationsController < Admin::AdminController
  active_scaffold :cse_annotation do |config|
    config.label = 'Google CSE Annotations'
    config.list.sorting = { :url => :asc }
  end
end