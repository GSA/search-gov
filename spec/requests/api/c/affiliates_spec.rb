require 'spec_helper'

describe SearchConsumer::Api do
  fixtures :affiliates, :navigations, :document_collections, :rss_feeds, :image_search_labels
  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:affiliate_config_url_path) { "/api/c/affiliate/config?site_handle=usagov&sc_access_key=#{SC_ACCESS_KEY}" }
  let(:collection) { affiliate.document_collections.first }

  before do
    affiliate.update_attributes(page_one_more_results_pointer: 'Custom Footer Text',
                                footer_fragment: 'Custom Footer Fragment')
  end

  context 'GET /api/c/affiliate?site_handle=:site_handle/config' do
    it "returns a serialized affiliate with search_type 'web', representing the config options (facet and module settings)" do

      get affiliate_config_url_path
      expect(response.status).to eq(200)

      response_hash =  JSON.parse response.body

      response_hash['defaults']['usasearchId'] = 1
      response_hash['defaults']['templateType'] = 'classic'
      # facet mocks
      response_hash['facets']['pageOneLabel'] = 'search'
      response_hash['facets']['facetLinks'][1]['channel_id'] = 1
      response_hash['facets']['facetLinks'][2]['docs_id'] = 1
      # Tagline Mocks
      response_hash['tagline']['logoUrl'] = 'http://logo_url'
      response_hash['tagline']['title'] = 'google'
      response_hash['tagline']['url'] = 'http://logo_url'
      # Header Mocks
      response_hash['header']['logoAlignment'] = 'left'
      response_hash['header']['logoAltText'] = 'Logo'
      response_hash['header']['logoImageUrl'] = 'http://logo_image_url'

      # css_property mocks
      response_hash['template']['CSS']['font_family'] = 'Helvetica'

      expect(response_hash).to eq({
        'defaults' => {
          'apiAccessKey' => 'usagov_key',
          'displayName' => 'USA.gov',
          'usasearchId' => 1,
          'locale' => 'en',
          'name' => 'usagov',
          'searchEngine' => 'Bing',
          'googleCX' => nil,
          'googleKey' => nil,
          'searchType' => 'web',
          'templateType' => 'classic',
          'website' => 'https://www.usa.gov',
          'external_tracking_code' => nil
        },
        'facets' => {
          'pageOneLabel'=>'search',
          'left_nav_label' => nil,
          'facetLinks'=>[
            {'name'=>'Images', 'type'=>'ImageSearchLabel', 'active'=>true},
            {'name'=>'Usa Gov Blog', 'type'=>'RSS', 'channel_id'=>1, 'active'=>true},
            {'name'=>'USAGov Collection', 'type'=>'DocumentCollection', 'docs_id'=>1, 'active'=>true}
          ],
          'CSS' => {
            'facets_background_color'=>'#F1F1F1',
            'active_facet_link_color'=>'#9E3030',
            'facet_link_color'=>'#505050'
          }
        },
        'footer'=> {
          'links'=>nil,
          'CSS'=> {
            'footer_background_color'=>'#DFDFDF',
            'footer_links_text_color'=>'#000000'
          },
          'page_one_more_results_pointer'=>'Custom Footer Text',
          'footer_fragment'=>'Custom Footer Fragment'
        },
        'header'=>{
          'logoImageUrl'=>'http://logo_image_url',
          'logoAlignment'=>'left',
          'logoAltText'=>'Logo',
          'CSS'=> {
            'header_background_color'=>'#FFFFFF',
            'header_text_color'=>'#000000'
          }
        },
        'headerLinks'=>{
          'links'=>nil,
          'headerLinksAlignment'=>nil,
          'CSS'=>{
            'header_links_background_color'=>'#F1F1F1',
            'header_links_text_color'=>'#000000'
          }
        },
        'govBoxes'=>{
          'rss'=>false,
          'video'=>true,
          'jobOpenings'=>false,
          'federalRegisterDocuments'=>false,
          'relatedSearches'=>true,
          'healthTopics'=>false,
          'typeaheadSearch'=>true
        },
        'noResultsPage'=>{
          'additionalGuidanceText'=>nil,
          'altLinks'=>nil
        },
        'resultsContainer'=>{
          'CSS'=>{
            'title_link_color'=>'#2200CC',
            'visited_title_link_color'=>'#800080',
            'result_url_color'=>'#006800',
            'description_text_color'=>'#000000'
          }
        },
        'searchBar'=>{
          'CSS'=>{
            'search_button_background_color'=>'#00396F'
          }
        },
        'searchPageAlert' => nil,
        'tagline'=>{
          'title'=>'google',
          'url'=>'http://logo_url',
          'logoUrl'=>'http://logo_url',
          'CSS'=>{
            'header_tagline_color'=>'#FFFFFF',
            'header_tagline_background_color'=>'#000000'
          }
        },
        'template'=>{
          'templateType'=>'Template::Classic',
          'faviconUrl'=>'http://favicon_logo.com',
          'CSS'=>{
            'page_background'=>'#DFDFDF',
            'default_font'=>'Tahoma',
            'font_family'=>'Helvetica'
          }
        },
        'related_sites'=>[],
        'document_collections'=>[
            {'id'=>collection.id,'name'=>'USAGov Collection','advanced_search_enabled'=>false}
        ]
      })
    end

    it "returns a serialized affiliate with search_type 'i14y', representing the config options (facet and module settings)" do
      affiliate.gets_i14y_results = true
      affiliate.save
      get affiliate_config_url_path
      expect(response.status).to eq(200)
      expect(response.body).to include_json({
        defaults: {
          searchType: 'i14y'
        }})
    end

    it "returns a serialized affiliate with search_type 'blended', representing the config options (facet and module settings)" do
      affiliate.gets_blended_results = true
      affiliate.save
      get affiliate_config_url_path
      expect(response.status).to eq(200)
      expect(response.body).to include_json({
        defaults: {
          searchType: 'blended'
        }})
    end

    it 'returns a 401 unauthorized if there is no valid sc_access_key param' do
      get '/api/c/affiliate/config?site_handle=usagov&sc_access_key=invalidKey'
      expect(response.status).to eq(401)
    end
  end


end
