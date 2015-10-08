class Sites::WatchersController < Sites::SetupSiteController
  before_filter :setup_watcher, only: [:edit, :update, :destroy]

  def index
    @watchers = @site.watchers
  end

  def new
    @watcher = @site.watchers.build
  end

  def create
    @watcher = @site.watchers.build watcher_params
    if @watcher.save
      redirect_to site_watchers_path(@site), flash: { success: "You have created a watcher" }
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @watcher.update_attributes(watcher_params)
      redirect_to edit_site_watcher_path(@site, @watcher.id), flash: { success: 'This watcher has been updated.' }
    else
      render action: :edit
    end
  end

  def destroy
    @watcher.destroy
    redirect_to site_watchers_path(@site), flash: { success: "You have removed the watcher" }
  end

  private

  def setup_watcher
    @watcher = @site.watchers.find_by_id params[:id]
    redirect_to site_watchers_path(@site) unless @watcher
  end

  def watcher_params
    params.require(:watcher).permit(:name, :throttle_period, :check_interval).merge(user_id: current_user.id)
  end

end
