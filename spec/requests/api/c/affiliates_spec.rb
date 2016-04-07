require 'spec_helper'

describe SearchConsumer::API do
  fixtures :affiliates, :navigations, :document_collections, :rss_feeds, :image_search_labels

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:affiliate_url_path) { "/api/c/affiliate?site_handle=usagov&sc_access_key=#{SC_ACCESS_KEY}" }

  context 'GET /api/c/affiliate?site_handle=:site_handle' do
    it 'returns a serialized affiliate by name' do
      get affiliate_url_path
      expect(last_response.status).to eq(200)
      expect(response.body).to eq({
        name: "usagov",
        usasearch_id: 130687165,
        display_name: "USA.gov",
        website: "http://www.usa.gov",
        api_access_key: "usagov_key",
        page_one_label: "search",
        locale: 'en',
        search_engine: "Bing",
        search_type: "web"
        }.to_json)
    end

    it 'returns a 401 unauthroized if there is no valid sc_access_key param' do
      get "/api/c/affiliate?site_handle=usagov&sc_access_key=invalidKey"
      expect(last_response.status).to eq(401)
    end
  end

  context 'PUT /api/c/affiliate?site_handle=:site_handle' do
    it 'updates an Affiliate' do
      put_hash = {
        affiliate_params: {
          display_name: "New USAGOV",
          website: "www.newusagov"
        }
      }.to_json
      put affiliate_url_path, put_hash, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 200
      expect(affiliate.display_name).to eq "New USAGOV"
      expect(affiliate.website).to eq "http://www.newusagov"
    end

    it 'returns a 401 unauthroized if there is no valid sc_access_key param' do
      put "/api/c/affiliate?site_handle=usagov&sc_access_key=invalidKey"
      expect(last_response.status).to eq(401)
    end
  end

  let(:affiliate_config_url_path) { "/api/c/affiliate/config?site_handle=usagov&sc_access_key=#{SC_ACCESS_KEY}" }

  context 'GET /api/c/affiliate?site_handle=:site_handle/config' do
    it "returns a serialized affiliate with search_type 'web', representing the config options (facet and module settings)" do
      get affiliate_config_url_path
      expect(last_response.status).to eq(200)
      expect(response.body).to eq({
        defaults: {
          name: "usagov",
          usasearch_id: 130687165,
          display_name: "USA.gov",
          website: "http://www.usa.gov",
          api_access_key: "usagov_key",
          page_one_label: "search",
          locale: 'en',
          search_engine: "Bing",
          search_type: "web"
        },
        facets:[
          {
            name: "Images",
            type: "ImageSearchLabel",
            active: true
          },
          {
            name: "Usa Gov Blog",
            type: "RSS",
            channel_id: rss_feeds(:usagov_blog).id,
            active: true
          },
          {
            name: "USAGov Collection",
            type: "DocumentCollection",
            docs_id: document_collections(:usagov_docs).id,
            active: true
          },
        ],
        modules: {
          rss_govbox: false,
          video: true,
          job_openings: false,
          federal_register_documents: false,
          related_searches: true,
          health_topics: false,
          typeahead_search: true
        }
      }.to_json)
    end

    it "returns a serialized affiliate with search_type 'i14y', representing the config options (facet and module settings)" do
      affiliate.gets_i14y_results = true
      affiliate.save
      get affiliate_config_url_path
      expect(last_response.status).to eq(200)
      expect(response.body).to include_json({
        defaults: {
          search_type: "i14y"
        }})
    end

    it "returns a serialized affiliate with search_type 'blended', representing the config options (facet and module settings)" do
      affiliate.gets_blended_results = true
      affiliate.save
      get affiliate_config_url_path
      expect(last_response.status).to eq(200)
      expect(response.body).to include_json({
        defaults: {
          search_type: "blended"
        }})
    end



    it 'returns a 401 unauthroized if there is no valid sc_access_key param' do
      get "/api/c/affiliate?site_handle=usagov&sc_access_key=invalidKey"
      expect(last_response.status).to eq(401)
    end
  end


end
