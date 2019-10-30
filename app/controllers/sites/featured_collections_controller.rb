class Sites::FeaturedCollectionsController < Sites::BestBetsController
  before_action :setup_featured_collection, only: %i[edit update destroy]

  def index
    @featured_collections = search_best_bets(FeaturedCollection)
  end

  def new
    @featured_collection = FeaturedCollection.new(publish_start_on: Date.current)
    build_children
  end

  def new_link
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def create
    @featured_collection = @site.featured_collections.build(featured_collection_params)
    create_best_bet(@featured_collection, site_best_bets_graphics_path(@site))
  end

  def update
    update_best_bet(@featured_collection, site_best_bets_graphics_path(@site), featured_collection_params)
  end

  def destroy
    destroy_best_bet(@featured_collection, site_best_bets_graphics_path(@site))
  end

  def build_children
    @featured_collection.featured_collection_keywords.build if @featured_collection.featured_collection_keywords.blank?
    @featured_collection.featured_collection_links.build if @featured_collection.featured_collection_links.blank?
  end

  private

  def setup_featured_collection
    @featured_collection = @site.featured_collections.find_by_id(params[:id])
    redirect_to site_best_bets_graphics_path(@site) unless @featured_collection
  end

  def featured_collection_params
    params.require(:featured_collection).permit(
      :image,
      :image_alt_text,
      :mark_image_for_deletion,
      :publish_start_on, :publish_end_on,
      :status, :title, :title_url,
      :match_keyword_values_only,
      featured_collection_keywords_attributes: %i[id value],
      featured_collection_links_attributes: %i[id title url position]
    ).to_h
  end
end
