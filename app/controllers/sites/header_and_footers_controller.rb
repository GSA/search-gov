# frozen_string_literal: true

class Sites::HeaderAndFootersController < Sites::SetupSiteController
  before_action :build_header_links, only: [:edit, :new_header_link]
  before_action :build_footer_links, only: [:edit, :new_footer_link]

  def edit
  end

  def new_header_link
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def new_footer_link
    @index = params[:index].to_i
    respond_to { |format| format.js }
  end

  def update
    if @site.update(site_params)
      redirect_to edit_site_header_and_footer_path(@site),
                  flash: { success: 'You have updated your header and footer information.' }
    else
      build_header_links
      build_footer_links
      render :edit
    end
  end

  private

  def build_header_links
    @site.managed_header_links = [{}] if @site.managed_header_links.blank?
  end

  def build_footer_links
    @site.managed_footer_links = [{}] if @site.managed_footer_links.blank?
  end

  def site_params
    site_params = params.require(:site).
      permit({ css_property_hash: %i(menu_button_alignment) },
             :header_tagline,
             :header_tagline_url,
             :mark_header_tagline_logo_for_deletion,
             :header_tagline_logo,
             { managed_footer_links_attributes: %i(position title url) },
             { managed_header_links_attributes: %i(position title url) })
    site_params[:css_property_hash] &&= @site.css_property_hash.merge(site_params[:css_property_hash])
    site_params
  end
end
