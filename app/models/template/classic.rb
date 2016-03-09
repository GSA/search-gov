class Template::Classic < Template
  HUMAN_READABLE_NAME = "Classic"
  TEMPLATE_DESCRIPTION = "This is the Default template for all Digital Gov Search Websites."
  
  DEFAULT_SCHEMA = {
    "css" => {
      "font" => {
        "default_font" => "Tahoma",
        "font_family" => "Tahoma, Verdana, Arial, sans-serif"
      },
      "colors" => {
        "template" => {
          "page_background" => "#EBE6DE"
        },
        "header" => {
          "header_background_color" => "#1B50A0",
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
        "results_container" => {
          "title_link_color" => "#154285",
          "visited_title_link_color" => "#595959",
          "url_link_color" => "#008000",
          "description_text_color" => "#000000"
        },
        "search_bar" => {
          "search_button_background_color" => "#DE6262"
        },
        "tagline" => {
          "header_tagline_color" => "#FFFFFF",
          "header_tagline_background_color" => "#000000"
        },
        "header_links" => {
        }
      }
    }
  }
end
