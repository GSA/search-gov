class WidgetsController < ApplicationController
  def top_searches
    @active_top_searches = TopSearch.find_active_entries
  end

  def trending_searches
    @active_top_searches = TopSearch.find_active_entries
    @widget_source = params[:widget_source]
    respond_to do |format|
      format.html
      format.xml { @widget_source = 'xml' if @widget_source.blank? }
    end
  end
end

