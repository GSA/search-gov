class WidgetsController < ApplicationController
  def top_searches
    @top_searches = TopSearch.find(:all, :limit => 5, :order => 'position asc')
    render :layout => false
  end
end

