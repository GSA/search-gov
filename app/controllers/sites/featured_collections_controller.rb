class Sites::FeaturedCollectionsController < Sites::SetupSiteController
  before_filter :setup_featured_collection, only: [:edit, :update, :destroy]

  def index
    @featured_collections = @site.featured_collections.substring_match(params[:query]).paginate(
        per_page: FeaturedCollection.per_page,
        page: params[:page],
        order: 'featured_collections.updated_at DESC, featured_collections.title ASC')
  end

  def new
    @featured_collection = FeaturedCollection.new(publish_start_on: Date.current)
    build_keywords_and_links
  end

  def new_keyword
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def new_link
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def create
    @featured_collection = @site.featured_collections.build(featured_collection_params)
    if @featured_collection.save
      redirect_to site_best_bets_graphics_path(@site),
                  flash: { success: "You have added #{@featured_collection.title} to this site." }
    else
      build_keywords_and_links
      render action: :new
    end
  end

  def edit
    build_keywords_and_links
  end

  def update
    if @featured_collection.destroy_and_update_attributes(featured_collection_params)
      redirect_to site_best_bets_graphics_path(@site),
                  flash: { success: "You have updated #{@featured_collection.title}." }
    else
      build_keywords_and_links
      render action: :edit
    end
  end

  def destroy
    @featured_collection.destroy
    redirect_to site_best_bets_graphics_path(@site),
                flash: { success: "You have removed #{@featured_collection.title} from this site." }
  end

  private

  def build_keywords_and_links
    @featured_collection.featured_collection_keywords.
        build if @featured_collection.featured_collection_keywords.blank?
    @featured_collection.featured_collection_links.
        build if @featured_collection.featured_collection_links.blank?
  end

  def featured_collection_params
    params.require(:featured_collection).
        permit(:image, :image_alt_text, :image_attribution, :image_attribution_url,
               :layout, :mark_image_for_deletion,
               :publish_start_on, :publish_end_on,
               :status, :title, :title_url,
               featured_collection_keywords_attributes: [:id, :value],
               featured_collection_links_attributes: [:id, :title, :url, :position])
  end

  def setup_featured_collection
    @featured_collection = @site.featured_collections.find_by_id(params[:id])
    redirect_to site_best_bets_graphics_path(@site) unless @featured_collection
  end
end
