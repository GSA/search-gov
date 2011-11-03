class Affiliates::OnDemandUrlsController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate

  VALID_CONTENT_TYPES = %w{text/plain txt}

  def index
    @title = "URLs - "
    @indexed_document = IndexedDocument.new
    @uncrawled_urls = IndexedDocument.uncrawled_urls(@affiliate, nil)
    @crawled_urls = IndexedDocument.crawled_urls(@affiliate, 1, 5)
  end

  def create
    @indexed_document = IndexedDocument.new(params[:indexed_document])
    @indexed_document.affiliate = @affiliate
    if @indexed_document.save
      flash[:success] = "Successfully added #{@indexed_document.url}.  It will be indexed soon."
    else
      flash[:error] = @indexed_document.errors.full_messages.to_sentence
    end
    redirect_to affiliate_on_demand_urls_path(@affiliate)
  end

  def destroy
    if @indexed_document = IndexedDocument.destroy(params[:id])
      flash[:success] = "Removed #{@indexed_document.url} from list of uncrawled URLs."
    end
    redirect_to affiliate_on_demand_urls_path(@affiliate)
  end

  def upload
    file = params[:indexed_documents]
    if file.present? and VALID_CONTENT_TYPES.include?(file.content_type)
      begin
        uploaded_count = IndexedDocument.process_file(file, @affiliate)
        if uploaded_count > 0
          flash[:success] = "Successfully uploaded #{uploaded_count} urls."
        else
          flash[:error] = "No urls uploaded; please check your file and try again."
        end
      rescue Exception => e
        flash[:error] = e.message
      end
    else
      flash[:error] = "Invalid file format; please upload a plain text file (.txt)."
    end
    redirect_to affiliate_on_demand_urls_path(@affiliate)
  end

  def crawled
    @title = 'Previously Crawled URLs - '
    @crawled_urls = IndexedDocument.crawled_urls(@affiliate, params[:page])
  end
end