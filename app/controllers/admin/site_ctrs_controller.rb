class Admin::SiteCtrsController < Admin::AdminController
  def show
    @page_title = 'Site CTRs'
    site_ctr = SiteCtr.new(7, params[:module_tag])
    @site_ctrs = site_ctr.site_ctrs
    @search_module = SearchModule.find_by_tag params[:module_tag]
  end

end
