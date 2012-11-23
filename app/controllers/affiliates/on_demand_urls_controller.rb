class Affiliates::OnDemandUrlsController < Affiliates::AffiliatesController
  EXPORT_CRAWLED_FIELDS = %w(url title description doctype last_crawled_at last_crawl_status)
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate

  def new
    @title = "Add a new URL - "
    @indexed_document = @affiliate.indexed_documents.build
  end

  def bulk_new
    @title = "Bulk Upload URLs - "
  end

  def create
    @indexed_document = @affiliate.indexed_documents.build(params[:indexed_document])
    if (bing_url = BingUrl.find_by_normalized_url(BingSearch.normalized_url(@indexed_document.url)))
      bing_url.destroy
    end
    if @indexed_document.save
      Resque.enqueue_with_priority(:high, IndexedDocumentFetcher, @indexed_document.id)
      redirect_to uncrawled_affiliate_on_demand_urls_path(@affiliate), :flash => { :success => "Successfully added #{@indexed_document.url}. It will be indexed soon." }
    else
      @title = "Add a new URL - "
      render :action => :new
    end
  end

  def destroy
    @indexed_document = @affiliate.indexed_documents.find_by_id(params[:id])
    redirect_to urls_and_sitemaps_affiliate_path(@affiliate) and return unless @indexed_document
    @indexed_document.destroy
    redirect_to :back, :flash => { :success => "Removed #{@indexed_document.url}." }
  end

  def upload
    file = params[:indexed_documents]
    result = IndexedDocument.process_file(file, @affiliate, current_user.is_affiliate_admin? ? 0 : IndexedDocument::MAX_URLS_PER_FILE_UPLOAD)
    if result[:success]
      redirect_to uncrawled_affiliate_on_demand_urls_path(@affiliate), :flash => { :success => "Successfully uploaded #{result[:count]} urls." }
    else
      @title = "Bulk Upload URLs - "
      flash.now[:error] = result[:error_message]
      render :action => :bulk_new
    end
  end

  def crawled
    @title = 'Previously Crawled URLs - '
    @crawled_urls = IndexedDocument.crawled_urls(@affiliate, params[:page])
    respond_to do |format|
      format.html
    end
  end

  def uncrawled
    @title = 'Uncrawled URLs - '
    @uncrawled_urls = IndexedDocument.uncrawled_urls(@affiliate, params[:page])
  end

  def export_crawled
    respond_to do |format|
      format.csv {
        csv_data = CSV.generate do |csv|
          csv << EXPORT_CRAWLED_FIELDS
          @affiliate.indexed_documents.fetched.select(EXPORT_CRAWLED_FIELDS).paginate(:page => 1, :per_page => 10000).each do |doc|
            description = doc.description.nil? ? '' : doc.description.squish
            csv << [doc.url, doc.title, description, doc.doctype, doc.last_crawled_at, doc.last_crawl_status]
          end
        end
        send_data csv_data, :type => 'text/csv', :filename => "#{@affiliate.name}-crawled-urls.csv", :disposition => 'attachment'
      }
    end
  end
end
