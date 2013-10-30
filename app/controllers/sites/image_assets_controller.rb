class Sites::ImageAssetsController < Sites::SetupSiteController
  def edit
  end

  def update
    if @site.update_attributes(site_params)
      redirect_to edit_site_image_assets_path(@site),
                  flash: { success: 'You have updated your image assets.' }
    else
      render :edit
    end
  end

  def site_params
    params.require(:site).permit(
        { css_property_hash: [:page_background_image_repeat] },
        :favicon_url,
        :header_image,
        :mark_header_image_for_deletion,
        :mark_mobile_logo_for_deletion,
        :mark_page_background_image_for_deletion,
        :mobile_logo,
        :page_background_image)
  end
end
