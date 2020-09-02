class Sites::FontAndColorsController < Sites::SetupSiteController
  def edit
  end

  def update
    if @site.update_attributes(site_params)
      redirect_to edit_site_font_and_colors_path(@site),
                  flash: { success: 'You have updated your font & colors.' }
    else
      render :edit
    end
  end

  private

  def site_params
    @site_params = params.require(:site).permit(
      {
        css_property_hash: %i[
          content_background_color
          content_border_color
          content_box_shadow_color
          description_text_color
          font_family
          footer_background_color
          footer_links_text_color
          header_links_background_color
          header_links_text_color
          header_text_color
          header_background_color
          header_tagline_background_color
          header_tagline_color
          header_tagline_font_family
          left_tab_text_color
          navigation_background_color
          navigation_link_color
          page_background_color
          search_button_background_color
          search_button_text_color
          show_content_border
          show_content_box_shadow
          title_link_color
          url_link_color
          visited_title_link_color
        ]
      },
      :theme
    ).to_h
    @site_params[:css_property_hash] = @site.css_property_hash.merge(@site_params[:css_property_hash])
    @site_params
  end
end
