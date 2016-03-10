require 'spec_helper'

describe SearchConsumer::API do
  fixtures :affiliates, :navigations, :document_collections, :rss_feeds, :image_search_labels

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:affiliate_config_url_path) { "/api/c/affiliate/config?site_handle=usagov&sc_access_key=#{SC_ACCESS_KEY}" }

  context 'GET /api/c/affiliate?site_handle=:site_handle/config' do
    it "returns a serialized affiliate with search_type 'web', representing the config options (facet and module settings)" do

      get affiliate_config_url_path
      expect(last_response.status).to eq(200)
      
      response_hash =  JSON.parse response.body
      
      response_hash["defaults"]["usasearchId"] = 1
      response_hash["defaults"]["templateType"] = 'classic'
      # facet mocks
      response_hash["facets"]["pageOneLabel"] = "search"
      response_hash["facets"]["facetLinks"][1]["channel_id"] = 1 
      response_hash["facets"]["facetLinks"][2]["docs_id"] = 1
      # Tagline Mocks
      response_hash["tagline"]["logoUrl"] = "http://logo_url"
      response_hash["tagline"]["title"] = "google"
      response_hash["tagline"]["url"] = "http://logo_url"
      # Header Mocks
      response_hash["header"]["logoAlignment"] = "left"
      response_hash["header"]["logoAltText"] = "Logo"
      response_hash["header"]["logoImageUrl"] = "http://logo_image_url"
      
      # css_property mocks
      response_hash["template"]["CSS"]["font_family"] = "Helvetica"

      expect(response_hash).to eq({
        "defaults" => {
          "apiAccessKey" => "usagov_key",
          "displayName" => "USA.gov",
          "usasearchId" => 1,
          "locale" => "en",
          "name" => "usagov",
          "searchEngine" => "Azure",
          "googleCX" => nil,
          "googleKey" => nil,
          "searchType" => "web",
          "templateType" => "classic",
          "website" => "http://www.usa.gov",
        },
        "facets" => {
          "pageOneLabel"=>"search", 
          "facetLinks"=>[
            {"name"=>"Images", "type"=>"ImageSearchLabel", "active"=>true}, 
            {"name"=>"Usa Gov Blog", "type"=>"RSS", "channel_id"=>1, "active"=>true}, 
            {"name"=>"USAGov Collection", "type"=>"DocumentCollection", "docs_id"=>1, "active"=>true}
          ], 
          "CSS" => {
            "active_facet_link_color"=>"#C61F0C", 
            "facets_background_color"=>"#854242", 
            "facet_link_color"=>"#154285"
          }
        },
        "footer"=> {
          "links"=>nil, 
          "CSS"=> {
            "footer_background_color"=>"#EBE6DE", 
            "footer_links_text_color"=>"#000000"
          }
        },
        "header"=>{
          "logoImageUrl"=>"http://logo_image_url", 
          "logoAlignment"=>"left", 
          "logoAltText"=>"Logo", 
          "headerLinksAlignment"=>nil, 
          "CSS"=> {
            "header_background_color"=>"#1B50A0", 
            "header_text_color"=>"#000000"
          }
        },
        "headerLinks"=>{
          "links"=>nil, 
          "CSS"=>{
          }
        }, 
        "govBoxes"=>{
          "rss"=>false, 
          "video"=>true, 
          "jobOpenings"=>false, 
          "federalRegisterDocuments"=>false, 
          "relatedSearches"=>true, 
          "healthTopics"=>false, 
          "typeaheadSearch"=>true
        },
        "noResultsPage"=>{
          "additionalGuidanceText"=>nil, 
          "altLinks"=>nil
        }, 
        "resultsContainer"=>{
          "CSS"=>{
            "title_link_color"=>"#154285", 
            "visited_title_link_color"=>"#595959", 
            "url_link_color"=>"#008000", 
            "description_text_color"=>"#000000"
          }
        }, 
        "searchBar"=>{
          "CSS"=>{
            "search_button_background_color"=>"#DE6262"
          }
        },
        "searchPageAlert" => nil,
        "tagline"=>{
          "title"=>"google", 
          "url"=>"http://logo_url", 
          "logoUrl"=>"http://logo_url", 
          "CSS"=>{
            "header_tagline_color"=>"#FFFFFF", 
            "header_tagline_background_color"=>"#000000"
          }
        },
        "template"=>{
          "templateType"=>"Template::Classic", 
          "faviconUrl"=>"http://favicon_logo.com", 
          "CSS"=>{
            "page_background"=>"#EBE6DE",
            "font_family"=>"Helvetica"
          }
        }
      })
    end

    it "returns a serialized affiliate with search_type 'i14y', representing the config options (facet and module settings)" do
      affiliate.gets_i14y_results = true
      affiliate.save
      get affiliate_config_url_path
      expect(last_response.status).to eq(200)
      expect(response.body).to include_json({
        defaults: {
          searchType: "i14y"
        }})
    end

    it "returns a serialized affiliate with search_type 'blended', representing the config options (facet and module settings)" do
      affiliate.gets_blended_results = true
      affiliate.save
      get affiliate_config_url_path
      expect(last_response.status).to eq(200)
      expect(response.body).to include_json({
        defaults: {
          searchType: "blended"
        }})
    end

    it 'returns a 401 unauthorized if there is no valid sc_access_key param' do
      get "/api/c/affiliate/config?site_handle=usagov&sc_access_key=invalidKey"
      expect(last_response.status).to eq(401)
    end
  end


end
