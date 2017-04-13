class Sites::IndexedDocumentsController < Sites::SetupSiteController
  before_filter :setup_site
  before_filter :setup_indexed_document, only: [:destroy]

  def index
=begin
GET http://localhost:9200/development-usasearch-elastic_indexed_documents-reader/elastic_indexed_document/_search?from=0&preference=_local&size=10 [status:200, request:0.015s, query:0.013s]
2017-04-12 16:50:21 -0700: > {"query":{"filtered":{"query":{"bool":{"must":[{"query_string":{"fields":["title","description","body"],"query":"visa","analyzer":"en_analyzer","default_operator":"AND"}}]}},"filter":{"bool":{"must":{"term":{"affiliate_id":6}}}}}},"highlight":{"pre_tags":[""],"post_tags":[""],"fields":{"title":{"number_of_fragments":0},"description":{"fragment_size":75,"number_of_fragments":2},"body":{"fragment_size":75,"number_of_fragments":2}}}}
=end
    search_params = { q: params[:query],
                      affiliate_id: @site.id,
                      language: @site.indexing_locale,
                      size: 10,
                      offset: (30 * (params[:page] || 1)) } #TODO: make this work without language?
    documents = (ElasticIndexedDocument.search_for(q: params[:query], affiliate_id: @site.id, language: @site.indexing_locale).results || [])
    @indexed_documents = documents.paginate(per_page: 30, page: params[:page]) #TODO: check pagination

    #OLD
    #  @indexed_documents = @site.indexed_documents.by_matching_url(params[:query]).paginate( page: params[:page]).order('id DESC')
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
        merge(source: 'manual', last_crawl_status: IndexedDocument::SUMMARIZED_STATUS)
  end
end
