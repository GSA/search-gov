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
      response_hash["template"]["CSS"]["fontFamily"] = "Helvetica"

      expect(response_hash).to eq({
        "defaults" => {
          "apiAccessKey" => "usagov_key",
          "displayName" => "USA.gov",
          "usasearchId" => 1,
          "locale" => "en",
          "name" => "usagov",
          "searchEngine" => "Azure",
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
            "activeFacetLinkColor"=>"#9E3030", 
            "facetsBackgroundColor"=>"#F1F1F1", 
            "facetLinkColor"=>"#505050"
          }
        },
        "footer"=> {
          "footerLinks"=>nil, 
          "CSS"=> {
            "footerBackgroundColor"=>"#DFDFDF", 
            "footerLinksTextColor"=>"#000000"
          }
        },
        "header"=>{
          "logoImageUrl"=>"http://logo_image_url", 
          "logoAlignment"=>"left", 
          "logoAltText"=>"Logo", 
          "headerLinksAlignment"=>nil, 
          "CSS"=> {
            "headerBackgroundColor"=>"#FFFFFF", 
            "headerTextColor"=>"#000000"
          }
        },
        "headerLinks"=>{
          "links"=>nil, 
          "CSS"=>{
            "headerLinksBackgroundColor"=>"#0068c4", 
            "headerLinksTextColor"=>"#fff"
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
            "titleLinkColor"=>"#2200CC", 
            "visitedTitleLinkColor"=>"#800080", 
            "urlLinkColor"=>"#006800", 
            "descriptionTextColor"=>"#000000"
          }
        }, 
        "searchBar"=>{
          "CSS"=>{
            "searchButtonBackgroundColor"=>"#00396F"
          }
        },
        "searchPageAlert" => nil,
        "tagline"=>{
          "title"=>"google", 
          "url"=>"http://logo_url", 
          "logoUrl"=>"http://logo_url", 
          "CSS"=>{
            "headerTaglineColor"=>"#FFFFFF", 
            "headerTaglineBackgroundColor"=>"#000000"
          }
        },
        "template"=>{
          "templateType"=>"classic", 
          "faviconUrl"=>"http://favicon_logo.com", 
          "CSS"=>{
            "fontFamily"=>"Helvetica", 
            "pageBackground"=>"#DFDFDF"
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
