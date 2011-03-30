class Analytics::QueryGroupsController < Analytics::AnalyticsAdminController
  active_scaffold :query_group do |config|
    config.columns = [:name, :updated_at, :grouped_queries]
    config.list.sorting = { :name => :asc }
    config.list.per_page = 100
    config.action_links.add "bulk_edit", :label => "Bulk Edit", :type => :member, :page => true
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
    redirect_to analytics_queries_path
  end

  def bulk_edit
    @query_group = QueryGroup.find(params[:id])
    if params[:grouped_queries_text].present?
      updated_queries = params[:grouped_queries_text].split("\n").collect{|query| query.chomp }
      # remove queries that are no longer in the list
      remove_list = []
      @query_group.grouped_queries.each do |grouped_query|
        if !updated_queries.include?(grouped_query.query)
          remove_list << grouped_query
        end
      end
      @query_group.grouped_queries.delete(remove_list)
      # add in new queries
      update_count = 0
      updated_queries.each do |query|
        if query.present? && @query_group.grouped_queries.find_by_query(query).nil?
          @query_group.grouped_queries << GroupedQuery.find_or_create_by_query(query)
          update_count += 1
        end
      end
      flash[:notice] = "#{update_count} queries added, #{remove_list.size} queries removed."
      @query_group.save
    elsif request.method == "POST"
      flash[:notice] = "#{@query_group.grouped_queries.size} queries removed."
      @query_group.grouped_queries.delete_all
    end
    @grouped_queries_text = @query_group.grouped_queries.reload.collect{|grouped_query| grouped_query.query }.join("\n")
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
