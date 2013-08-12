class Sites::BoostedContentsController < Sites::BaseController
  include ActionView::Helpers::TextHelper
  before_filter :setup_site
  before_filter :setup_boosted_content, only: [:edit, :update, :destroy]

  def index
    @boosted_contents = @site.boosted_contents.paginate(
        per_page: BoostedContent.per_page,
        page: params[:page],
        order: 'updated_at DESC, title ASC')
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
      index_boosted_content
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
      index_boosted_content
      redirect_to site_best_bets_texts_path(@site),
                  flash: { success: "You have updated #{@boosted_content.title}." }
    else
      build_keywords
      render action: :edit
    end
  end

  def destroy
    @boosted_content.destroy
    @boosted_content.solr_remove_from_index
    redirect_to site_best_bets_texts_path(@site),
                flash: { success: "You have removed #{@boosted_content.title} from this site." }
  end

  def new_bulk_upload
  end

  def bulk_upload
    results = BoostedContent.bulk_upload(@site, bulk_upload_params)
    if results[:success]
      messages = []
      messages << 'Bulk upload is complete.'
      messages << "You have added #{pluralize(results[:created], 'Best Bets: Text')}."
      messages << "You have updated #{pluralize(results[:updated], 'Best Bets: Text')}." if results[:updated] > 0
      redirect_to site_best_bets_texts_path(@site),
                  flash: { success: "#{messages.join('<br/>')}".html_safe }
    else
      flash.now[:error] = results[:error_message]
      render action: :new_bulk_upload
    end
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

  def index_boosted_content
    Sunspot.index @boosted_content
  end

  def bulk_upload_params
    params.permit(:best_bets_text_data_file)[:best_bets_text_data_file]
  end
end
