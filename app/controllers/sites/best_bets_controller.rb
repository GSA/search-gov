class Sites::BestBetsController < Sites::SetupSiteController

  def search_best_bets(klass)
    name = klass.name.tableize
    @site.send(name).substring_match(params[:query]).paginate(
      per_page: klass.per_page,
      page: params[:page]).order("#{name}.updated_at DESC, #{name}.title ASC")
  end

  def new_keyword
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def edit
    build_children
  end

  def create_best_bet(best_bet, redirect_path)
    if best_bet.save
      redirect_to redirect_path, flash: { success: "You have added #{best_bet.title} to this site." }
    else
      build_children
      render action: :new
    end
  end

  def update_best_bet(best_bet, redirect_path, params)
    if best_bet.destroy_and_update_attributes(params)
      redirect_to redirect_path, flash: { success: "You have updated #{best_bet.title}." }
    else
      build_children
      render action: :edit
    end
  end

  def destroy_best_bet(best_bet, redirect_path)
    best_bet.destroy
    redirect_to redirect_path, flash: { success: "You have removed #{best_bet.title} from this site." }
  end
end
