class HelpDocsController < ApplicationController
  before_filter :require_usasearch_url_param
  respond_to :json

  def show
    respond_with ({ body: HelpDoc.extract_article(params[:url]) })
  end

  private

  def require_usasearch_url_param
    redirect_to page_not_found_path unless params[:url] =~ %r[^http://usasearch\.howto\.gov/.+]i
  end
end
