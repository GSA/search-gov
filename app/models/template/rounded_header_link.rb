class Template::RoundedHeaderLink < Template
  HUMAN_READABLE_NAME = "Rounded Header Links"
  TEMPLATE_DESCRIPTION = "In this template, the Header Menu appears as rounded pills above the search bar and facets appear below the search bar."
  
  DEFAULT_SCHEMA = {
    "css" => {
      "font" => {
        "default_font" => "Tahoma",
        "font_family" => "Tahoma, Verdana, Arial, sans-serif"
      },
      "colors" => {
        "template" => {
          "page_background" => "#084D8B"
        },
        "header" => {
          "header_text_color" => "#000000"
        },
        "facets" => {
          "active_facet_link_color" => "#C61F0C",
          "facets_background_color" => "#854242",
          "facet_link_color" => "#154285"
        },
        "footer" => {
          "footer_background_color" => "#EBE6DE",
          "footer_links_text_color" => "#000000"
        },
        "header_links" => {
          "header_links_background_color" => "#0068C4",
          "header_links_text_color" => "#FFFFFF"
        },
        "results_container" => {
          "title_link_color" => "#154285",
          "visited_title_link_color" => "#595959",
          "url_link_color" => "#008000",
          "description_text_color" => "#000000"
        },
        "search_bar" => {
          "search_button_background_color" => "#084D8B"
        },
        "tagline" => {
          "header_tagline_color" => "#FFFFFF",
          "header_tagline_background_color" => "#000000"
        }
      }
    }
  }
end
