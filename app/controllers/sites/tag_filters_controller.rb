class Sites::TagFiltersController < Sites::SetupSiteController
  before_action :setup_site
  before_action :setup_tag_filter, only: [:destroy]

  def index
  end

  def new
    @tag_filter = @site.tag_filters.build
  end

  def create
    @tag_filter = @site.tag_filters.build tag_filter_params
    if @tag_filter.save
      redirect_to site_tag_filters_path(@site),
                  flash: { success: "You have added the tag #{@tag_filter.tag} to this site." }
    else
      render action: :new
    end
  end

  def destroy
    @tag_filter.destroy
    redirect_to site_tag_filters_path(@site),
                flash: { success: "You have removed the tag #{@tag_filter.tag} from this site." }
  end

  private

  def setup_tag_filter
    @tag_filter = @site.tag_filters.find_by_id params[:id]
    redirect_to site_tag_filters_path(@site) unless @tag_filter
  end

  def tag_filter_params
    params.require(:tag_filter).permit(:tag, :exclude)
  end
end
