class Sites::SiteFeedUrlsController < Sites::SetupSiteController
  before_action :setup_site
  before_action :setup_site_feed_url

  def edit
  end

  def create
    update
  end

  def update
    if @site_feed_url.update_attributes site_feed_url_params
      Resque.enqueue_with_priority(:high, SiteFeedUrlFetcher, @site_feed_url.id)
      redirect_to edit_site_supplemental_feed_path(@site),
                  flash: { success: 'You have updated your supplemental feed for this site.' }
    else
      render action: :edit
    end
  end

  def destroy
    @site_feed_url.destroy
    redirect_to edit_site_supplemental_feed_path(@site),
                flash: { success: 'You have removed your supplemental feed from this site.' }
  end

  private

  def setup_site_feed_url
    @site_feed_url = @site.site_feed_url || @site.build_site_feed_url
  end

  def site_feed_url_params
    @site_feed_url_params ||= params.require(:site_feed_url).
        permit(:rss_url).
        merge(last_checked_at: nil, last_fetch_status: 'Pending').to_h
  end
end
