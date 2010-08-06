class Analytics::QueryGroupsController < Analytics::AnalyticsController
  active_scaffold :query_group do |config|
    config.columns = [:name, :updated_at, :grouped_queries]
    config.list.sorting = { :name => :asc }
  end
  
  def bulk_add
    query_group = QueryGroup.find_or_create_by_name(params[:query_group])
    query_terms = collect_query_terms(params)
    query_terms.each do |query_term|
      query_group.grouped_queries << GroupedQuery.find_or_create_by_query(query_term) rescue nil
    end
    flash[:notice] = "The following queries were added to the '#{query_group.name}' query group:<br/>&nbsp;&nbsp;#{query_terms.join(', ')}"
    redirect_to :back
  end
  
  private
  
  def collect_query_terms(params)
    query_terms = params.collect do |key, value|
      value if key[0..7] == 'bulk_add'
    end
    query_terms.compact
  end
end