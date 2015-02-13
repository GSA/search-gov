class Admin::SearchModuleCtrsController < Admin::AdminController
  def show
    @page_title = 'Search Module CTRs'
    search_module_ctr = SearchModuleCtr.new(7)
    @search_module_ctrs = search_module_ctr.search_module_ctrs
  end

end
