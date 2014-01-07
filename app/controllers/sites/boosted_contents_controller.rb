class Sites::BoostedContentsController < Sites::SetupSiteController
  before_filter :setup_boosted_content, only: [:edit, :update, :destroy]

  def index
    @boosted_contents = @site.boosted_contents.substring_match(params[:query]).paginate(
        per_page: BoostedContent.per_page,
        page: params[:page],
        order: 'boosted_contents.updated_at DESC, boosted_contents.title ASC')
  end

  def new
    @boosted_content = BoostedContent.new(publish_start_on: Date.current)
    build_keywords
  end

  def new_keyword
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def create
    @boosted_content = @site.boosted_contents.build(boosted_content_params)
    if @boosted_content.save
      redirect_to site_best_bets_texts_path(@site),
                  flash: { success: "You have added #{@boosted_content.title} to this site." }
    else
      build_keywords
      render action: :new
    end
  end

  def edit
    build_keywords
  end

  def update
    if @boosted_content.destroy_and_update_attributes(boosted_content_params)
      redirect_to site_best_bets_texts_path(@site),
                  flash: { success: "You have updated #{@boosted_content.title}." }
    else
      build_keywords
      render action: :edit
    end
  end

  def destroy
    @boosted_content.destroy
    redirect_to site_best_bets_texts_path(@site),
                flash: { success: "You have removed #{@boosted_content.title} from this site." }
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
               boosted_content_keywords_attributes: [:id, :value])
  end

  def build_keywords
    @boosted_content.boosted_content_keywords.
        build if @boosted_content.boosted_content_keywords.blank?
  end

end
