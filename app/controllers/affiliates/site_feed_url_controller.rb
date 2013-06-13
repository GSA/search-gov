class Affiliates::SiteFeedUrlController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  DEFAULT_URL_LIMIT = 1000

  def create
    site_feed_url = SiteFeedUrl.new(affiliate: @affiliate, rss_url: params[:site_feed_url][:rss_url], quota: DEFAULT_URL_LIMIT )
    if site_feed_url.save
      Resque.enqueue_with_priority(:high, SiteFeedUrlFetcher, site_feed_url.id)
      flash_hash = {success: 'RSS site feed URL added. It will be fetched soon for indexing.'}
    else
      flash_hash = {error: "Problem creating RSS site feed: #{site_feed_url.errors.full_messages.join}"}
    end
    redirect_to urls_affiliate_path(@affiliate), flash: flash_hash
  end

  def update
    site_feed_url = SiteFeedUrl.find_or_initialize_by_affiliate_id @affiliate.id
    site_feed_url.rss_url = params[:site_feed_url][:rss_url]
    if site_feed_url.save
      Resque.enqueue_with_priority(:high, SiteFeedUrlFetcher, site_feed_url.id)
      flash_hash = {success: 'RSS site feed URL updated. It will be fetched soon for indexing.'}
    else
      flash_hash = {error: "Problem updating RSS site feed: #{site_feed_url.errors.full_messages.join}"}
    end
    redirect_to urls_affiliate_path(@affiliate), flash: flash_hash
  end

  def destroy
    site_feed_url = @affiliate.site_feed_url
    redirect_to urls_affiliate_path(@affiliate) and return unless site_feed_url.present?
    site_feed_url.destroy
    redirect_to :back, :flash => { :success => "Removed site feed URL #{site_feed_url.rss_url} and all indexed documents." }
  end

end

