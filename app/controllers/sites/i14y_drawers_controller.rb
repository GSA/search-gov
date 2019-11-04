class Sites::I14yDrawersController < Sites::SetupSiteController
  include ::Hintable

  before_action :setup_i14y_drawer, only: [:edit, :update, :destroy, :show]
  before_action :load_hints, only: %i(new)

  def index
    @i14y_drawers = @site.i14y_drawers
  end

  def show
    search_params = {
                      handles: @i14y_drawer.handle,
                      query: params[:query],
                      size: 100,
                      include: 'title,path,created,changed,updated_at',
                      sort_by_date: true,
                      language: @site.locale,
                    }
    documents = (I14yCollections.search(search_params).results || [])
    @i14y_documents = documents.paginate(per_page: 20, page: params[:page])
  end

  def new
    @i14y_drawer = @site.i14y_drawers.build
  end

  def create
    @i14y_drawer = @site.i14y_drawers.build i14y_drawer_params
    if @i14y_drawer.save
      redirect_to site_i14y_drawers_path(@site),
                  flash: { success: "You have created the #{@i14y_drawer.handle} i14y drawer. Your secret token is #{@i14y_drawer.token}" }
    else
      load_hints
      render action: :new
    end
  end

  def edit
  end

  def update
    @i14y_drawer.update_attributes i14y_drawer_params
    redirect_to site_i14y_drawers_path(@site),
                flash: { success: "You have updated the #{@i14y_drawer.handle} i14y drawer." }

  end

  def destroy
    if @i14y_drawer.affiliates.count == 1
      @i14y_drawer.destroy
      success_message = "You have deleted the #{@i14y_drawer.handle} i14y drawer and all of its contents."
    else
      @i14y_drawer.i14y_memberships.find_by_affiliate_id(@site.id).destroy
      success_message = "You have removed the #{@i14y_drawer.handle} i14y drawer from this site."
    end
    redirect_to site_i14y_drawers_path(@site), flash: { success: success_message }
  end

  private

  def setup_i14y_drawer
    @i14y_drawer = @site.i14y_drawers.find_by_id params[:id]
    redirect_to site_i14y_drawers_path(@site) unless @i14y_drawer
  end

  def i14y_drawer_params
    params.require(:i14y_drawer).permit(:handle, :description)
  end
end
