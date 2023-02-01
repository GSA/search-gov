require 'spec_helper'

describe ApiI14ySearch do
  let(:affiliate) { affiliates(:i14y_affiliate) }

  # NOTE: See spec/spec_helper.rb for an explanation of how i14y response data is stubbed.
  # TLDR, a query for 'marketplase' with @include_facets=false or missing will stub
  # spec/fixtures/json/i14y/marketplace.json.  A query for 'faq' with @include_facets=true
  # will stub spec/fixtures/json/i14y/faq.json.
  describe '#as_json' do
    subject(:search) do
      agency = Agency.create!({ name: 'Some New Agency', abbreviation: 'SNA' })
      AgencyOrganizationCode.create!(organization_code: 'XX00', agency: agency)
      allow(affiliate).to receive(:agency).and_return(agency)

      described_class.new affiliate: affiliate,
                          enable_highlighting: highlight,
                          limit: 20,
                          next_offset_within_limit: next_offset,
                          offset: 0,
                          query: query
    end

    let(:query) { 'marketplase' }
    let(:highlight) { true }
    let(:next_offset) { true }

    context 'when highlighting is enabled' do
      before do
        allow(GovboxSet).to receive(:new).with('marketplase',
                                               affiliate,
                                               nil,
                                               highlighting: true,
                                               pre_tags: ["\ue000"],
                                               post_tags: ["\ue001"])
        search.run
      end

      it 'sets results total' do
        expect(search.as_json[:web][:total]).to eq(270)
      end

      it 'returns results count' do
        expect(search.as_json[:web][:results].count).to eq(20)
      end

      it 'sets spelling suggestion' do
        expect(search.as_json[:web][:spelling_correction]).to eq('marketplace')
      end

      it 'highlights title and description' do
        result = Hashie::Mash.new(search.as_json[:web][:results].first)
        expect(result.title).to eq("\ue000Marketplace\ue001")
        expect(result.url).to eq('https://www.healthcare.gov/glossary/marketplace')
        expect(result.snippet).to eq("See Health Insurance \ue000Marketplace\ue001...More info on Health Insurance \ue000Marketplace\ue001")
        expect(result.publication_date).to eq(Date.parse('2013-06-05'))
      end

      it_behaves_like 'an API search as_json'
    end

    context 'when highlighting is disabled' do
      let(:highlight) { false }

      before do
        allow(GovboxSet).to receive(:new).with('marketplase',
                                               affiliate,
                                               nil,
                                               highlighting: false,
                                               pre_tags: ["\ue000"],
                                               post_tags: ["\ue001"])
        search.run
      end

      it 'returns non highlighted results' do
        result = Hashie::Mash.new(search.as_json[:web][:results].first)
        expect(result.title).to eq('Marketplace')
        expect(result.url).to eq('https://www.healthcare.gov/glossary/marketplace')
        expect(result.snippet).to eq('See Health Insurance Marketplace...More info on Health Insurance Marketplace')
        expect(result.publication_date).to eq(Date.parse('2013-06-05'))
      end
    end

    context 'when include_facets is true' do
      let(:web_hash) { search.as_json[:web] }
      let(:query) { 'faq' }

      before do
        search.instance_variable_set(:@include_facets, true)
        allow(I14ySearch).to receive(:new).with(search)
        search.run
      end

      it 'sets include_facets to true' do
        expect(web_hash[:include_facets]).to be true
      end

      it 'includes facet fields in response' do
        first_result = web_hash[:results].first
        expect(first_result.keys).to include(:audience,
                                             :content_type,
                                             :updated_date,
                                             :mime_type,
                                             :searchgov_custom1,
                                             :searchgov_custom2,
                                             :searchgov_custom3,
                                             :tags)
      end

      it 'returns aggregations' do
        expect(web_hash).to include(:aggregations)
      end

      it 'returns agg_key string and doc_count' do
        aggs_hash = web_hash[:aggregations].first
        random_agg = aggs_hash.keys.sample
        expect(aggs_hash[random_agg].first).
          to match hash_including(agg_key: be_a(String),
                                  doc_count: be_an(Integer))
      end
    end

    context 'when include_facets is false' do
      let(:web_hash) { search.as_json[:web] }

      before do
        search.instance_variable_set(:@include_facets, false)
        allow(I14ySearch).to receive(:new).with(search)
        search.run
      end

      it 'sets include_facets to false' do
        expect(web_hash[:include_facets]).to be false
      end

      it 'does not include facet fields in response' do
        first_result = web_hash[:results].first
        expect(first_result.keys).not_to include(:audience,
                                                 :content_type,
                                                 :updated_date,
                                                 :mime_type,
                                                 :tags)
      end

      it 'includes default fields in response' do
        first_result = web_hash[:results].first
        expect(first_result.keys).to include(:title,
                                             :url,
                                             :snippet,
                                             :publication_date)
      end

      it 'does not return aggregations' do
        expect(web_hash).not_to include(:aggregations)
      end
    end

    context 'when next_offset_within_limit is true' do
      before { search.run }

      it 'sets next_offset' do
        expect(search.as_json[:web][:next_offset]).to eq(20)
      end
    end

    context 'when next_offset_within_limit is false' do
      let(:next_offset) { false }

      before { search.run }

      it 'sets next_offset to nil' do
        expect(search.as_json[:web][:next_offset]).to be_nil
      end
    end
  end
end
