class Affiliates::RssFeedsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :setup_rss_feed, :only => [:show, :edit, :update, :destroy]

  def index
    @rss_feeds = @affiliate.rss_feeds.paginate(per_page: 10, page: params[:page])
  end

  def new
    @rss_feed = @affiliate.rss_feeds.build
  end

  def create
    RssFeed.transaction do
      @rss_feed = @affiliate.rss_feeds.build(params[:rss_feed].except(:rss_feed_urls_attributes))
      find_or_initialize_rss_feed_urls(@rss_feed, params[:rss_feed][:rss_feed_urls_attributes])
      if @rss_feed.save
        redirect_to [@affiliate, @rss_feed], flash: { success: 'RSS feed successfully created.' }
      else
        render action: :new
      end
    end
  end

  def edit
  end

  def update
    RssFeed.transaction do
      @rss_feed.assign_attributes params[:rss_feed].except(:rss_feed_urls_attributes)
      find_or_initialize_rss_feed_urls(@rss_feed, params[:rss_feed][:rss_feed_urls_attributes])
      if @rss_feed.save
        redirect_to [@affiliate, @rss_feed], flash: { success: 'RSS feed successfully updated.' }
      else
        render action: :edit
      end
    end
  end

  def show
  end

  def destroy
    @rss_feed.destroy
    redirect_to affiliate_rss_feeds_path(@affiliate), flash: { success: 'RSS feed successfully deleted.' }
  end

  def new_url_fields
  end

  private

  def setup_rss_feed
    @rss_feed = @affiliate.rss_feeds.find_by_id(params[:id])
    redirect_to @affiliate unless @rss_feed
  end
end
