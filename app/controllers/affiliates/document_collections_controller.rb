class Affiliates::DocumentCollectionsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :setup_document_collection, :only => [:show, :edit, :update, :destroy]

  def index
    @title = 'Collection -'
    @document_collections = @affiliate.document_collections
  end

  def new
    @title = 'Add a new Collection - '
    @document_collection = @affiliate.document_collections.new
    setup_blank_url_prefixes
  end

  def create
    @document_collection = @affiliate.document_collections.build(params[:document_collection])
    if @document_collection.save
      Emailer.deep_collection_notification(current_user, @document_collection).deliver if @document_collection.depth >= DocumentCollection::DEPTH_WHEN_BING_FAILS
      redirect_to [@affiliate, @document_collection], :flash => { :success => 'Collection successfully added.' }
    else
      @title = 'Add a new Collection - '
      setup_blank_url_prefixes
      render :action => :new
    end
  end

  def show
    @title = "Collections - "
  end

  def edit
    @title = 'Edit Collections entry - '
    setup_blank_url_prefixes
  end

  def update
    if @document_collection.destroy_and_update_attributes(params[:document_collection])
      redirect_to [@affiliate, @document_collection], :flash => { :success => 'Collections entry successfully updated.' }
    else
      @title = 'Edit Collections entry - '
      setup_blank_url_prefixes
      render :action => :edit
    end
  end

  def destroy
    @document_collection.destroy
    redirect_to affiliate_document_collections_path(@affiliate), :flash => { :success => 'Collections entry successfully deleted.' }
  end

  private
  def setup_document_collection
    @document_collection = @affiliate.document_collections.find_by_id(params[:id])
    redirect_to @affiliate unless @document_collection
  end

  def setup_blank_url_prefixes
    (2 - (@document_collection.url_prefixes.size)).times { @document_collection.url_prefixes.build }
  end

end
