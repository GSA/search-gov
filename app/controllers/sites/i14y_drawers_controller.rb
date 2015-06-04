class Sites::I14yDrawersController < Sites::SetupSiteController
  include ::Hintable

  before_filter :setup_i14y_drawer, only: [:edit, :update, :destroy, :show]
  before_filter :load_hints, only: %i(new)

  def index
    @i14y_drawers = @site.i14y_drawers
  end

  def show
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
    @i14y_drawer.destroy
    redirect_to site_i14y_drawers_path(@site),
                flash: { success: "You have deleted the #{@i14y_drawer.handle} i14y drawer and all of its contents." }
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
