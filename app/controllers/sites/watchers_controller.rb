class Sites::WatchersController < Sites::SetupSiteController
  include ::Hintable
  WATCHER_TYPES = [NoResultsWatcher, LowQueryCtrWatcher]
  COMMON_DEFAULTS = { throttle_period: '1d', check_interval: '30m', time_window: '12h' }
  before_action :setup_watcher, only: [:edit, :update, :destroy]
  before_action :load_hints, only: %i(new edit)

  def index
    @watchers = @site.watchers.where(user_id: current_user.id)
  end

  def new
    @watcher = watcher_type.new(COMMON_DEFAULTS.merge(watcher_type::WATCHER_DEFAULTS))
  end

  def create
    @watcher = watcher_type.new watcher_params
    if @watcher.save
      redirect_to site_watchers_path(@site), flash: { success: "You have created a watcher" }
    else
      load_hints
      render action: :new
    end
  end

  def edit
  end

  def update
    if @watcher.update_attributes(watcher_params)
      redirect_to site_watchers_path(@site), flash: { success: 'This watcher has been updated.' }
    else
      load_hints
      render action: :edit
    end
  end

  def destroy
    @watcher.destroy
    redirect_to site_watchers_path(@site), flash: { success: "You have removed the watcher" }
  end

  private

  def setup_watcher
    @watcher = watcher_type.where(id: params[:id], affiliate_id: @site.id, user_id: current_user.id).first
    redirect_to site_watchers_path(@site) unless @watcher
  end

  def watcher_params
    params.require(watcher_type.to_s.underscore).
      permit(:check_interval, :distinct_user_total, :low_ctr_threshold, :name, :query_blocklist,
             :search_click_total, :throttle_period, :time_window).
      merge(user_id: current_user.id, affiliate_id: @site.id)
  end

  def watcher_type
    WATCHER_TYPES.find { |type| params[:type] == type.to_s }
  end

  def hint_name_key(hint_name)
    "#{params[:type].underscore.sub('watcher','')}#{hint_name}"
  end

end
