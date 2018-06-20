require 'spec_helper'

describe ApiI14ySearch do
  fixtures :affiliates, :i14y_drawers, :i14y_memberships

  let(:affiliate) { affiliates(:i14y_affiliate) }

  describe '#as_json' do
    context 'when highlighting is enabled' do
      subject(:search) do
        agency = Agency.create!({:name => 'Some New Agency', :abbreviation => 'SNA' })
        AgencyOrganizationCode.create!(organization_code: "XX00", agency: agency)
        allow(affiliate).to receive(:agency).and_return(agency)

        described_class.new affiliate: affiliate,
                            enable_highlighting: true,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'marketplase'
      end

      before do
        expect(GovboxSet).to receive(:new).with('marketplase',
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

      it_should_behave_like 'an API search as_json'
    end

    context 'when highlighting is disabled' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: false,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'marketplase'
      end

      before do
        expect(GovboxSet).to receive(:new).with('marketplase',
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

    context 'when next_offset_within_limit is true' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: true,
                            limit: 20,
                            next_offset_within_limit: true,
                            offset: 0,
                            query: 'marketplase'
      end

      before { search.run }

      it 'sets next_offset' do
        expect(search.as_json[:web][:next_offset]).to eq(20)
      end
    end

    context 'when next_offset_within_limit is false' do
      subject(:search) do
        described_class.new affiliate: affiliate,
                            enable_highlighting: true,
                            limit: 20,
                            next_offset_within_limit: false,
                            offset: 0,
                            query: 'marketplase'
      end

      before { search.run }

      it 'sets next_offset to nil' do
        expect(search.as_json[:web][:next_offset]).to be_nil
      end
    end
  end
end
