class Sites::RoutedQueriesController < Sites::SetupSiteController
  include ::Hintable

  before_action :setup_routed_query, only: %i[edit update destroy]
  before_action :load_hints, only: %i(edit new create new_routed_query_keyword)

  def index
    @routed_queries = @site.routed_queries
  end

  def new
    @routed_query = @site.routed_queries.build
    build_routed_query_keyword
  end

  def new_routed_query_keyword
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def create
    @routed_query = @site.routed_queries.build routed_query_params
    if @routed_query.save
      redirect_with_success('added')
    else
      build_routed_query_keyword
      render action: :new
    end
  end

  def edit
    build_routed_query_keyword
  end

  def update
    if @routed_query.destroy_and_update_attributes(routed_query_params)
      redirect_with_success('updated')
    else
      build_routed_query_keyword
      load_hints
      render action: :edit
    end
  end

  def destroy
    redirect_to(site_routed_queries_path(@site)) && return unless @routed_query
    keywords = @routed_query.routed_query_keywords.pluck(:keyword).sort

    @routed_query.destroy
    redirect_with_success('removed', keywords)
  end

  private

  def setup_routed_query
    @routed_query = @site.routed_queries.find_by_id params[:id]
    redirect_to site_routed_queries_path(@site) unless @routed_query
  end

  def routed_query_params
    params.require(:routed_query).permit(
      :url,
      :description,
      routed_query_keywords_attributes: %i[id keyword]
    ).to_h
  end

  def build_routed_query_keyword
    @routed_query.routed_query_keywords.build if @routed_query.routed_query_keywords.empty?
  end

  def redirect_with_success(what, keywords = nil)
    kw = keywords || @routed_query.routed_query_keywords.pluck(:keyword).sort
    k = kw.map { |k| "'#{k}'" }.join(', ')
    redirect_to site_routed_queries_path(@site),
                flash: { success: "You have #{what} query routing for the following search term#{kw.count > 1 ? 's' : ''}: #{k}" }
  end
end
