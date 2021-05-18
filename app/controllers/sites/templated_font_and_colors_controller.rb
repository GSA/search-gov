# deprecated - Search Consumer
class Sites::TemplatedFontAndColorsController < Sites::SetupSiteController
  def edit

  end

  def update
    # reject debug template_schema_params.to_s
    if @site.save_template_schema(template_schema_params)
      @site.reset_template_schema if params[:reset_theme]
    end
    redirect_to edit_site_templated_font_and_colors_path(@site),
                  flash: { success: "You have succesfully updated your Font & Colors." }
  end

  private

  def template_schema_params
    params.require(:schema).permit(css:
      [
        {font: [
            :default_font,
            :font_family
          ]
        },
        {colors: [
          {header: [
            :header_text_color,
            :header_background_color,
          ]},
          {facets: [
            :active_facet_link_color,
            :facets_background_color,
            :facet_link_color
          ]},
          {footer: [
            :footer_background_color,
            :footer_links_text_color
          ]},
          {header_links: [
            :header_links_background_color,
            :header_links_text_color
          ]},
          {results_container: [
            :title_link_color,
            :visited_title_link_color,
            :result_url_color,
            :description_text_color
          ]},
          {search_bar: [
            :search_button_background_color
          ]},
          {tagline: [
            :header_tagline_color,
            :header_tagline_background_color
          ]},
          {header_links: [
          ]},
          {template: [
            :page_background
          ]}
        ]}
      ]
    )
  end
end
