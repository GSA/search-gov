# frozen_string_literal: true

describe DomainScopeOptionsBuilder do
  describe '.build' do
    subject(:build) { described_class.build(**args) }

    let(:affiliate) { affiliates(:basic_affiliate) }

    it 'includes the site domains' do
      expect(described_class.build(site: affiliate)).to eq(
        { included_domains: ['nps.gov'], excluded_domains: [], scope_ids: [], site_limits: nil }
      )
    end

    context 'when the affiliate has excluded domains' do
      before { affiliate.excluded_domains.create!(domain: 'excluded.gov') }

      it 'includes the included and excluded domains' do
        expect(described_class.build(site: affiliate)).to eq(
          { included_domains: ['nps.gov'], excluded_domains: ['excluded.gov'], scope_ids: [], site_limits: nil }
        )
      end
    end

    context 'when args include a document collection' do
      let(:collection) { document_collections(:sample) }

      it 'uses the collection prefixes as the included domains' do
        expect(described_class.build(site: affiliate, collection: collection)).to eq(
          { included_domains: ['www.something.gov/subfolder/'], excluded_domains: [], scope_ids: [], site_limits: nil }
        )
      end
    end

    context 'when a sitelimit is passed' do
      let(:args) do
        { site: affiliate, site_limits: 'https://nps.gov/foo' }
      end

      it 'strips out the protocols' do
        expect(build).to eq(
          included_domains: ['nps.gov'],
          excluded_domains: [],
          scope_ids: [],
          site_limits: 'nps.gov/foo'
        )
      end
    end

    context 'when multiple sitelimits are passed' do
      let(:args) do
        { site: affiliate, site_limits: 'https://nps.gov/foo https://nps.gov/bar' }
      end

      it 'strips out the protocols from multiple sites' do
        expect(build).to eq(
          included_domains: ['nps.gov'],
          excluded_domains: [],
          scope_ids: [],
          site_limits: 'nps.gov/foo nps.gov/bar'
        )
      end
    end
  end
end
