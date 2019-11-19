class Sites::DocumentCollectionsController < Sites::SetupSiteController
  include ::Hintable

  before_action :setup_collection, only: %i[show edit update destroy]
  before_action :load_hints, only: %i(edit new new_url_prefix)

  def index
    @document_collections = @site.document_collections
  end

  def new
    @document_collection = @site.document_collections.build
    build_url_prefix
  end

  def new_url_prefix
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def create
    @document_collection = @site.document_collections.build(collection_params)
    if @document_collection.save
      @document_collection.assign_sitelink_generator_names!
      notify_if_collection_too_deep
      redirect_to site_collections_path(@site),
                  flash: { success: "You have added #{@document_collection.name} to this site." }
    else
      build_url_prefix
      load_hints
      render action: :new
    end
  end

  def show
  end

  def edit
    build_url_prefix
  end

  def update
      if @document_collection.destroy_and_update_attributes(collection_params)
        @document_collection.assign_sitelink_generator_names!
        notify_if_collection_too_deep
        redirect_to site_collections_path(@site),
                    flash: { success: "You have updated #{@document_collection.name}." }
      else
        build_url_prefix
        load_hints
        render action: :edit
      end
  end

  def destroy
    @document_collection.destroy
    redirect_to site_collections_path(@site),
                flash: { success: "You have removed #{@document_collection.name} from this site." }
  end

  private

  def build_url_prefix
    @document_collection.url_prefixes.build if @document_collection.url_prefixes.blank?
  end

  def notify_if_collection_too_deep
    if @document_collection.too_deep_for_bing?
      Emailer.deep_collection_notification(current_user, @document_collection).deliver_now
    end
  end

  def setup_collection
    @document_collection = @site.document_collections.find_by_id(params[:id])
    redirect_to site_collections_path(@site) unless @document_collection
  end

  def collection_params
    params.require(:document_collection).permit(
      :name,
      url_prefixes_attributes: %i[id prefix]
    ).to_h
  end
end
