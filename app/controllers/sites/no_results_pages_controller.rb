class Sites::NoResultsPagesController < Sites::SetupSiteController
  include ::Hintable

  before_action :load_hints, only: %i[edit]
  before_action :build_no_results_pages_alt_links, only: [:edit, :new_no_results_pages_alt_link]

  def edit
  end

  def update
    if @site.update_attributes(site_params)
      redirect_to edit_site_no_results_pages_path(@site),
                  flash: { success: 'You have updated your No Results Page.' }
    else
      load_hints
      build_no_results_pages_alt_links
      render :edit
    end
  end

  def new_no_results_pages_alt_link
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  private

  def site_params
    params.require(:no_results_pages).permit(
          :additional_guidance_text,
          managed_no_results_pages_alt_links_attributes: %i[position title url]
        ).to_h
  end

  def build_no_results_pages_alt_links
    @site.managed_no_results_pages_alt_links = [{}] if @site.managed_no_results_pages_alt_links.blank?
  end
end
