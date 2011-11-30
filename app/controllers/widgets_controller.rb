class WidgetsController < ApplicationController
  def trending_searches
    @affiliate = Affiliate.find_by_id(params[:aid]) if params[:aid].present?
    @active_top_searches = @affiliate ? @affiliate.active_top_searches : TopSearch.find_active_entries
    @widget_source = params[:widget_source]
    respond_to do |format|
      format.html
      format.xml { @widget_source = 'xml' if @widget_source.blank? }
    end
  end
end