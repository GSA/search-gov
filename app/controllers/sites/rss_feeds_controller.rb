class Sites::RssFeedsController < Sites::SetupSiteController
  include ActionView::Helpers::TextHelper
  before_action :setup_rss_feed, only: [:show, :edit, :update]
  before_action :setup_non_managed_rss_feed, only: [:destroy]

  def index
    @rss_feeds = @site.rss_feeds
  end

  def new
    @rss_feed = @site.rss_feeds.build
    build_url
  end

  def new_url
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def create
    RssFeed.transaction do
      @rss_feed = @site.rss_feeds.build(rss_feed_params.except(:rss_feed_urls_attributes))
      assign_rss_feed_urls(rss_feed_params[:rss_feed_urls_attributes])
      if @rss_feed.save
        redirect_to site_rss_feeds_path(@site),
                    flash: { success: "You have added #{@rss_feed.name} to this site." }
      else
        build_url
        render action: :new
      end
    end
  end

  def show
  end

  def edit
    build_url
  end

  def update
    RssFeed.transaction do
      @rss_feed.assign_attributes rss_feed_params.except(:rss_feed_urls_attributes)
      unless @rss_feed.is_managed?
        assign_rss_feed_urls(rss_feed_params[:rss_feed_urls_attributes])
      end
      if @rss_feed.save
        redirect_to site_rss_feeds_path(@site),
                    flash: { success: "You have updated #{@rss_feed.name}." }
      else
        build_url
        render action: :edit
      end
    end
  end

  def destroy
    @rss_feed.destroy
    redirect_to site_rss_feeds_path(@site),
                flash: { success: "You have removed #{@rss_feed.name} from this site." }
  end

  private

  def build_url
    @rss_feed.rss_feed_urls.build if @rss_feed.rss_feed_urls.blank?
  end

  def assign_rss_feed_urls(attributes)
    existing_rss_feed_urls = []
    new_urls = []

    rss_feed_urls_attributes = attributes || {}
    rss_feed_urls_attributes.each_value do |url_attributes|
      url = url_attributes[:url]
      next if url.blank?
      rss_feed_url = RssFeedUrl.rss_feed_owned_by_affiliate.find_existing_or_initialize url
      if rss_feed_url.new_record?
        new_urls << rss_feed_url.url
      else
        existing_rss_feed_urls << rss_feed_url
      end
    end

    @rss_feed.rss_feed_urls = existing_rss_feed_urls
    new_urls.each do |url|
      @rss_feed.rss_feed_urls.build(rss_feed_owner_type: 'Affiliate', url: url)
    end
  end

  def setup_rss_feed
    @rss_feed = @site.rss_feeds.find_by_id(params[:id])
    redirect_to site_rss_feeds_path(@site) unless @rss_feed
  end

  def rss_feed_params
    params.require(:rss_feed).permit(:name,
                                     :show_only_media_content,
                                     { rss_feed_urls_attributes: [:url] }).to_h
  end

  def setup_non_managed_rss_feed
    @rss_feed = @site.rss_feeds.non_managed.find_by_id(params[:id])
    redirect_to site_rss_feeds_path(@site) unless @rss_feed
  end
end
