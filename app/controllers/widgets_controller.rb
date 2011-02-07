class WidgetsController < ApplicationController
  def top_searches
    @top_searches = TopSearch.find(:all, :limit => 5, :order => 'position asc')
    render :layout => false
  end

  def trending_searches
    @trending_searches = TopSearch.find(:all, :limit => 4, :order => 'position asc')
    render :partial => 'shared/trending_searches', :layout => true
  end
end

