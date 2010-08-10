class Analytics::QueryGroupsController < Analytics::AnalyticsController
  active_scaffold :query_group do |config|
    config.columns = [:name, :updated_at, :grouped_queries]
    config.list.sorting = { :name => :asc }
  end
  
  def bulk_add
    query_group = QueryGroup.find_or_create_by_name(params[:query_group])
    query_terms = collect_query_terms(params)
    duplicate_count = 0
    query_terms.each do |query_term|
      if query_group.grouped_queries.find_by_query(query_term).nil?
        query_group.grouped_queries << GroupedQuery.find_or_create_by_query(query_term)
      else
        duplicate_count += 1
      end
    end
    flash[:notice] = flash_notice(query_terms, duplicate_count, query_group.name)
    redirect_to analytics_home_page_path
  end
  
  private
  
  def collect_query_terms(params)
    query_terms = params.collect do |key, value|
      value if key[0..7] == 'bulk_add'
    end
    query_terms.compact
  end
  
  def flash_notice(query_terms, duplicate_count, query_group_name)
    flash = "#{query_terms.size - duplicate_count} queries added to group '#{query_group_name}'"
    flash += "; #{duplicate_count} duplicates ignored." if duplicate_count > 0
    flash
  end
end