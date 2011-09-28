class Affiliates::RssFeedsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :setup_rss_feed, :only => [:show, :edit, :update, :destroy]


  def index
    @title = 'RSS Feeds - '
    @rss_feeds = @affiliate.rss_feeds.paginate(:all, :per_page => 10, :page => params[:page])
  end
  
  def new
    @title = 'Add a new RSS Feed - '
    @rss_feed = @affiliate.rss_feeds.build
  end
  
  def create
    @rss_feed = @affiliate.rss_feeds.build(params[:rss_feed])
    if @rss_feed.save
      redirect_to [@affiliate, @rss_feed], :flash => { :success => 'RSS feed successfully created.' }
    else
      redirect_to new_affiliate_rss_feed_path(@affiliate)
    end
  end
  
  def edit
    @title = 'Edit RSS Feed - '
  end
  
  def update
    if @rss_feed.update_attributes(params[:rss_feed])
      redirect_to [@affiliate, @rss_feed], :flash => { :success => 'RSS feed successfully updated.' }
    else
      redirect_to edit_affiliate_rss_feed_path(@affiliate, @rss_feed)
    end
  end
  
  def show
    @title = "RSS Feed - "
  end
  
  def destroy
    @rss_feed.destroy
    redirect_to affiliate_rss_feeds_path(@affiliate), :flash => { :success => 'RSS feed successfully deleted.' }
  end
  
  private
  
  def setup_rss_feed
    @rss_feed = @affiliate.rss_feeds.find_by_id(params[:id])
    redirect_to @affiliate unless @rss_feed
  end
end