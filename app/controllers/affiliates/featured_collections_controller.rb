class Affiliates::FeaturedCollectionsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :setup_featured_collection, :only => [:show, :edit, :update, :destroy]

  def index
    @title = 'Featured Collections - '
    @featured_collections = @affiliate.featured_collections.paginate(:all, :per_page => FeaturedCollection.per_page, :page => params[:page])
  end

  def new
    @title = 'Add a new Featured Collection - '
    @featured_collection = @affiliate.featured_collections.build
    setup_blank_keywords_and_links
  end

  def create
    @featured_collection = @affiliate.featured_collections.build(params[:featured_collection])
    if @featured_collection.save
      redirect_to [@affiliate, @featured_collection], :flash => { :success => 'Feature Collection successfully created.' }
    else
      @title = 'Add a new Featured Collection - '
      setup_blank_keywords_and_links
      render :action => :new
    end
  end

  def show
    @title = "Featured Collection: #{@featured_collection.title} - "
  end

  def edit
    @title = 'Edit Featured Collection - '
    setup_blank_keywords_and_links
  end

  def update
    if @featured_collection.destroy_and_update_attributes(params[:featured_collection])
      redirect_to [@affiliate, @featured_collection], :flash => { :success => 'Featured Collection successfully updated.' }
    else
      @title = 'Edit Featured Collection - '
      setup_blank_keywords_and_links
      render :action => :edit
    end
  end

  def destroy
    @featured_collection.destroy
    redirect_to affiliate_featured_collections_path(@affiliate), :flash => { :success => 'Featured Collection successfully deleted.' }
  end

  private
  def setup_featured_collection
    @featured_collection = @affiliate.featured_collections.find_by_id(params[:id])
    redirect_to @affiliate unless @featured_collection
  end

  def setup_blank_keywords_and_links
    @featured_collection.featured_collection_keywords.build if @featured_collection.featured_collection_keywords.blank?
    (2 - (@featured_collection.featured_collection_links.size)).times { @featured_collection.featured_collection_links.build }
  end
end
