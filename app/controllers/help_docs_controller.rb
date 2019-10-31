class HelpDocsController < ApplicationController
  respond_to :json
  before_action :require_usasearch_url_param
  before_action :require_user

  def show
    respond_with ({ body: HelpDoc.extract_article(help_docs_params[:url]) })
  end

  private

  def require_usasearch_url_param
    unless help_docs_params[:url] =~ %r{\Ahttps?://search\.gov/.+\z}i
      redirect_to(Rails.application.secrets.organization['page_not_found_url'])
    end
  end

  def help_docs_params
    @help_docs_params ||= params.permit(:url)
  end

  def require_user
    unless current_user
      render(json: { error: 'login required' },
             status: :bad_request)
    end
  end
end
