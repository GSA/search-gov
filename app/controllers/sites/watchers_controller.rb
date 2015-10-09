class Sites::WatchersController < Sites::SetupSiteController
  WATCHER_TYPES = [NoResultsWatcher]
  before_filter :setup_watcher, only: [:edit, :update, :destroy]

  def index
    @watchers = @site.watchers
  end

  def new
    @watcher = watcher_type.new
  end

  def create
    @watcher = watcher_type.new watcher_params
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
      redirect_to site_watchers_path(@site), flash: { success: 'This watcher has been updated.' }
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
    @watcher = watcher_type.where(id: params[:id], affiliate_id: @site.id).first
    redirect_to site_watchers_path(@site) unless @watcher
  end

  def watcher_params
    params.require(params[:type].underscore).merge(user_id: current_user.id, affiliate_id: @site.id)
  end

  def watcher_type
    watcher_klass = params[:type].constantize
    watcher_klass if watcher_klass.in? WATCHER_TYPES
  end

end
