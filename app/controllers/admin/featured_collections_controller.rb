class Admin::FeaturedCollectionsController < Admin::AffiliatesController
  before_filter :setup_featured_collection, :only => [:show, :edit, :update, :destroy]
  before_filter :setup_page_parent_title, :only => [:new, :create, :show, :edit, :update]

  def index
    @page_title = 'Search.USA.gov Featured Collections'
    @featured_collections = FeaturedCollection.where(:affiliate_id => nil).paginate(:per_page => FeaturedCollection.per_page, :page => params[:page])
  end

  def new
    @page_title = 'Add a new Featured Collection'
    @featured_collection = FeaturedCollection.new(:publish_start_on => Date.current)
    setup_blank_keywords_and_links
  end

  def create
    @featured_collection = FeaturedCollection.new(params[:featured_collection])
    if @featured_collection.save
      redirect_to [:admin, @featured_collection], :flash => { :success => 'Featured Collection successfully created.' }
    else
      @page_title = 'Add a new Featured Collection'
      setup_blank_keywords_and_links
      render :action => :new
    end
  end

  def show
    @featured_collection = FeaturedCollection.where(:id => params[:id], :affiliate_id => nil).first
    @page_title = "Featured Collection"
  end

  def edit
    @featured_collection = FeaturedCollection.where(:id => params[:id], :affiliate_id => nil).first
    @page_title = 'Edit Featured Collection'
    setup_blank_keywords_and_links
  end

  def update
    @featured_collection = FeaturedCollection.where(:id => params[:id], :affiliate_id => nil).first
    if @featured_collection.destroy_and_update_attributes(params[:featured_collection])
      redirect_to [:admin, @featured_collection], :flash => { :success => 'Featured Collection successfully updated.' }
    else
      @page_title = 'Edit Featured Collection'
      setup_blank_keywords_and_links
      render :action => :edit
    end
  end

  def destroy
    @featured_collection = FeaturedCollection.where(:id => params[:id], :affiliate_id => nil).first
    @featured_collection.destroy
    redirect_to admin_featured_collections_path, :flash => { :success => 'Featured Collection successfully deleted.' }
  end

  private
  def setup_featured_collection
    @featured_collection = FeaturedCollection.where(:id => params[:id], :affiliate_id => nil).first
    redirect_to admin_featured_collections_path unless @featured_collection
  end

  def setup_blank_keywords_and_links
    @featured_collection.featured_collection_keywords.build if @featured_collection.featured_collection_keywords.blank?
    (2 - (@featured_collection.featured_collection_links.size)).times { @featured_collection.featured_collection_links.build }
  end

  def setup_page_parent_title
    @page_parent_title = "Search.USA.gov Featured Collections"
  end
end
