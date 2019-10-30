class Sites::IndexedDocumentsController < Sites::SetupSiteController
  before_action :setup_site
  before_action :setup_indexed_document, only: [:destroy]

  def index
    @indexed_documents = @site.indexed_documents.by_matching_url(params[:query]).paginate(
      page: params[:page]).order('id DESC')
  end

  def new
    @indexed_document = @site.indexed_documents.build
  end

  def create
    @indexed_document = @site.indexed_documents.build indexed_document_params
    if @indexed_document.save
      Resque.enqueue_with_priority(:high, IndexedDocumentFetcher, @indexed_document.id)
      redirect_to site_supplemental_urls_path(@site),
                  flash: { success: "You have added #{UrlParser.strip_http_protocols(@indexed_document.url)} to this site." }
    else
      render action: :new
    end
  end

  def destroy
    @indexed_document.destroy if @indexed_document.source_manual?
    redirect_to site_supplemental_urls_path(@site),
                flash: { success: "You have removed #{UrlParser.strip_http_protocols(@indexed_document.url)} from this site." }
  end

  private

  def setup_indexed_document
    @indexed_document = @site.indexed_documents.find_by_id params[:id]
    redirect_to site_supplemental_urls_path(@site) unless @indexed_document
  end

  def indexed_document_params
    params.require(:indexed_document).
      permit(:description, :title, :url).
      merge(
        source: 'manual',
        last_crawl_status: IndexedDocument::SUMMARIZED_STATUS
      ).to_h
  end
end
