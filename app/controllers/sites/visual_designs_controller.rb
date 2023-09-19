# frozen_string_literal: true

class Sites::VisualDesignsController < Sites::SetupSiteController
  def edit; end

  def update
    if @site.update(site_params)
      redirect_to edit_site_visual_design_path(@site),
                  flash: { success: 'You have updated your visual design settings.' }
    else
      render :edit,
             header_logo: @site.reload.header_logo,
             identifier_logo: @site.reload.identifier_logo
    end
  end

  private

  def site_params
    params.require(:site).permit(
      :use_extended_header,
      :favicon_url,
      :header_logo,
      :identifier_logo,
      header_logo_attachment_attributes: attachment_attributes,
      header_logo_blob_attributes: blob_attributes,
      identifier_logo_attachment_attributes: attachment_attributes,
      identifier_logo_blob_attributes: blob_attributes,
      visual_design_json: [
        :header_links_font_family,
        :footer_and_results_font_family,
        color_params
      ]
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
