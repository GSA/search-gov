class WidgetsController < ApplicationController
  def trending_searches
    @affiliate = params[:aid].present? ? Affiliate.find_by_id(params[:aid]) : Affiliate.find_by_name('usagov')
    if @affiliate
      @active_top_searches = @affiliate.active_top_searches
      @widget_source = params[:widget_source]
      respond_to do |format|
        format.html
        format.xml { @widget_source = 'xml' if @widget_source.blank? }
      end
    else
      @error_message = 'affiliate not found'
      respond_to do |format|
        format.html { render :text => @error_message, :status => :not_found }
        format.xml { render :xml => { :error_message => @error_message }.to_xml(:root => 'trending_searches'), :status => :not_found }
      end
    end
  end
end