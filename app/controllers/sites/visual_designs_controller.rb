# frozen_string_literal: true

class Sites::VisualDesignsController < Sites::SetupSiteController
  def edit; end

  def update
    if @site.update(site_params)
      redirect_to edit_site_visual_design_path(@site),
                  flash: { success: 'You have updated your visual design settings.' }
    else
      render :edit,
             header_logo: @site.reload.header_logo
    end
  end

  private

  def site_params
    params.require(:site).permit(
      :use_extended_header,
      :display_image_on_search_results,
      :display_filetype_on_search_results,
      :display_created_date_on_search_results,
      :display_updated_date_on_search_results,
      :display_logo_only,
      :show_vote_org_link,
      :favicon_url,
      :header_logo,
      header_logo_attachment_attributes: attachment_attributes,
      header_logo_blob_attributes: blob_attributes,
      visual_design_json: [
        :footer_and_results_font_family,
        :header_links_font_family,
        :primary_navigation_font_family,
        :primary_navigation_font_weight,
        color_params
      ],
      primary_header_links_attributes: %i[title url position id _destroy],
      secondary_header_links_attributes: %i[title url position id _destroy],
      footer_links_attributes: %i[title url position id _destroy]
    )
  end

  def color_params
    Affiliate::DEFAULT_COLORS.keys
  end

  def attachment_attributes
    [:id,
     :_destroy]
  end

  def blob_attributes
    [
      :checksum,
      :id,
      { custom_metadata: [
        :alt_text
      ] }
    ]
  end
end
