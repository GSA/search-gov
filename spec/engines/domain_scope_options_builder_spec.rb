require 'spec_helper'

describe DomainScopeOptionsBuilder do
  fixtures :affiliates, :site_domains, :document_collections, :url_prefixes

  describe '.build' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    subject(:build) { DomainScopeOptionsBuilder.build(args) }


    it 'includes the site domains' do
      expect(DomainScopeOptionsBuilder.build(site: affiliate)).to eq(
        {:included_domains=>['nps.gov'], :excluded_domains=>[], :scope_ids=>[], :site_limits=>nil}
      )
    end

    context 'when the affiliate has excluded domains' do
      before { affiliate.excluded_domains.create!(domain: 'excluded.gov') }

      it 'includes the included and excluded domains' do
        expect(DomainScopeOptionsBuilder.build(site: affiliate)).to eq(
          { included_domains: ['nps.gov'], excluded_domains: ['excluded.gov'], scope_ids: [], site_limits: nil}
        )
      end
    end

    context 'when args include a document collection' do
      let(:collection) { document_collections(:sample) }
      it 'uses the collection prefixes as the included domains' do
        expect(DomainScopeOptionsBuilder.build(site: affiliate, collection: collection)).to eq(
          { included_domains: ['www.something.gov/subfolder/'], excluded_domains: [], scope_ids: [], site_limits: nil}
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

    context 'when a sitelimit is passed' do
      let(:args) do
        { site: affiliate, site_limits: 'https://nps.gov/foo+https://nps.gov/bar' }
      end

      it 'strips out the protocols from multiple sites' do
        expect(build).to eq(
          included_domains: ['nps.gov'],
          excluded_domains: [],
          scope_ids: [],
          site_limits: 'nps.gov/foo+nps.gov/bar'
        )
      end
    end
  end
end
