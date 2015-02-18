class Admin::QueryCtrsController < Admin::AdminController
  def show
    @page_title = 'Query CTRs'
    query_ctr = QueryCtr.new(7, params[:module_tag], params[:site_name])
    @query_ctrs = query_ctr.query_ctrs
    @search_module = SearchModule.find_by_tag params[:module_tag]
    @site = Affiliate.find_by_name params[:site_name]
  end

end
