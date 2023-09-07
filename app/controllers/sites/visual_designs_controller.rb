# frozen_string_literal: true

class Sites::VisualDesignsController < Sites::SetupSiteController
  before_action :build_links, only: [:edit, :new_link]

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

  def new_link
    @index = params[:index].to_i
    @type = params[:type]
    respond_to { |format| format.js }
  end

  private

  def build_links
    @site.primary_header_links = [{}] if @site.primary_header_links.blank?
    @site.secondary_header_links = [{}] if @site.secondary_header_links.blank?
    @site.footer_links = [{}] if @site.footer_links.blank?
    @site.identifier_links = [{}] if @site.identifier_links.blank?
  end

  def site_params
    params.require(:site).permit(
      :use_extended_header,
      :favicon_url,
      :header_logo,
      :identifier_logo,
      :identifier_domain_name,
      :parent_agency_name,
      :parent_agency_link,
      header_logo_attachment_attributes: attachment_attributes,
      header_logo_blob_attributes: blob_attributes,
      identifier_logo_attachment_attributes: attachment_attributes,
      identifier_logo_blob_attributes: blob_attributes,
      visual_design_json: [
        :header_links_font_family,
        :footer_and_results_font_family,
        color_params
      ],
      links_json: [
        {
          primary_header_links: [links_attributes],
          secondary_header_links: [links_attributes],
          footer_links: [links_attributes],
          identifier_links: [links_attributes]
        }
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

  def links_attributes
    %i[position title url]
  end
end
