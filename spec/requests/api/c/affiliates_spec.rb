require 'spec_helper'

describe SearchConsumer::API do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:affiliate_url_path) { "/api/c/affiliates/usagov?sc_access_key=#{SC_ACCESS_KEY}" }

  context 'GET /api/c/affiliates/:name' do
    it 'returns a serialized affiliate by name' do
      get affiliate_url_path
      expect(last_response.status).to eq(200)
      expect(response.body).to eq SearchConsumer::Entities::Affiliate.represent(affiliate).to_json()
    end

    it 'returns a 401 unauthroized if there is no valid sc_access_key param' do
      get "/api/c/affiliates/usagov?sc_access_key=invalidKey"
      expect(last_response.status).to eq(401)
    end
  end

  context 'PUT /api/c/affiliates/:name' do
    it 'updates an Affiliate' do
      post_hash = {
        affiliate_params: {
          display_name: "New USAGOV",
          website: "www.newusagov"
        }
      }.to_json
      put "#{affiliate_url_path}", post_hash, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 200
      expect(affiliate.display_name).to eq "New USAGOV"
      expect(affiliate.website).to eq "http://www.newusagov"
    end

    it 'returns a 401 unauthroized if there is no valid sc_access_key param' do
      post "/api/c/affiliates/usagov?sc_access_key=invalidKey"
      expect(last_response.status).to eq(401)
    end
  end
end