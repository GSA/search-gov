class Sites::DisplaysController < Sites::SetupSiteController
  def edit
    build_connection
  end

  def new_connection
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def update
    if @site.destroy_and_update_attributes(site_params)
      redirect_to edit_site_display_path(@site),
                  flash: { success: 'You have updated your site display settings.' }
    else
      build_connection
      render :edit
    end
  end

  private

  def build_connection
    @site.connections.build if @site.connections.blank?
  end

  def site_params
    params.require(:site).permit(
        :default_search_label,
        :is_federal_register_document_govbox_enabled,
        :is_medline_govbox_enabled,
        :is_related_searches_enabled,
        :is_sayt_enabled,
        :is_rss_govbox_enabled,
        :is_video_govbox_enabled,
        :jobs_enabled,
        :left_nav_label,
        :rss_govbox_label,
        :i14y_date_stamp_enabled,
        :template_type,
        connections_attributes: [:id, :affiliate_name, :label, :position],
        document_collections_attributes: navigable_attributes,
        image_search_label_attributes: navigable_attributes,
        rss_feeds_attributes: navigable_attributes)
  end

  def navigable_attributes
    [:id,
     :name,
     { navigation_attributes:
       [:id, :position, :is_active] }].freeze
  end
end
