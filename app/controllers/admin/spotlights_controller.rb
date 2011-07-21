class Admin::SpotlightsController < Admin::AdminController
  active_scaffold :spotlight do |config|
    config.columns = [:updated_at, :title, :is_active, :notes, :spotlight_keywords, :affiliate]
    writables = [:title, :is_active, :notes, :html, :spotlight_keywords, :affiliate]
    config.create.columns = writables
    config.update.columns = writables
    config.list.sorting = { :updated_at => :desc }
    config.columns[:affiliate].form_ui= :select
  end
  
  before_filter :clean_params, :only => [:create, :update]
  
  def clean_params
    params.each do |key,value|
      if key =~ /record.*html_editor/
        params.delete(key)
      end
    end
  end
end