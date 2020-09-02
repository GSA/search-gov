class Sites::BoostedContentsController < Sites::BestBetsController
  before_action :setup_boosted_content, only: [:edit, :update, :destroy]

  def index
    @boosted_contents = search_best_bets(BoostedContent)
  end

  def new
    @boosted_content = BoostedContent.new(publish_start_on: Date.current)
    build_children
  end

  def create
    @boosted_content = @site.boosted_contents.build(boosted_content_params)
    create_best_bet(@boosted_content, site_best_bets_texts_path(@site))
  end

  def update
    update_best_bet(@boosted_content, site_best_bets_texts_path(@site), boosted_content_params)
  end

  def destroy
    destroy_best_bet(@boosted_content, site_best_bets_texts_path(@site))
  end

  def build_children
    @boosted_content.boosted_content_keywords.build if @boosted_content.boosted_content_keywords.blank?
  end

  private

  def setup_boosted_content
    @boosted_content = @site.boosted_contents.find_by_id(params[:id])
    redirect_to site_best_bets_texts_path(@site) unless @boosted_content
  end

  def boosted_content_params
    params.require(:boosted_content).
        permit(:url, :title, :description, :status,
               :publish_start_on, :publish_end_on,
               :match_keyword_values_only,
               boosted_content_keywords_attributes: [:id, :value]).to_h
  end

end
