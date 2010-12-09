class AffiliateSuperfreshController < AffiliateAuthController
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate
  
  VALID_CONTENT_TYPES = %w{text/plain txt}
  
  def index
    @title = "Add to Bing - "
    @superfresh_url = SuperfreshUrl.new
    @uncrawled_urls = SuperfreshUrl.uncrawled_urls(nil, @affiliate)
    @crawled_urls = SuperfreshUrl.crawled_urls(@affiliate, params[:page])
  end

  def create
    @superfresh_url = SuperfreshUrl.new(params[:superfresh_url])
    @superfresh_url.affiliate = @affiliate
    if @superfresh_url.save
      flash[:success] = "Successfully added #{@superfresh_url.url}.  It will be refreshed soon."
    else
      flash[:error] = "There was an error adding the URL to be refreshed.  Please check the URL and try again."
    end
    redirect_to affiliate_superfresh_urls_path(@affiliate)
  end
  
  def destroy
    if @superfresh_url = SuperfreshUrl.destroy(params[:id])
      flash[:success] = "Removed #{@superfresh_url.url} from list of uncrawled URLs."
    end
    redirect_to affiliate_superfresh_urls_path(@affiliate)
  end
  
  def upload
    file = params[:superfresh_urls]
    if VALID_CONTENT_TYPES.include?(file.content_type)
      begin    
        uploaded_count = SuperfreshUrl.process_file(file, @affiliate)
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
    redirect_to affiliate_superfresh_urls_path(@affiliate)
  end
end
  
