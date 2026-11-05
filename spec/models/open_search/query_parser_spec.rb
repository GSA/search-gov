# frozen_string_literal: true

require 'spec_helper'

describe OpenSearch::QueryParser do
  describe '#site_filters' do
    subject(:site_filters) { described_class.new(query).site_filters }

    context 'when the query includes a leading-dot TLD site filter' do
      let(:query) { 'gov site:.gov' }

      it 'strips the leading dot so PathHierarchy tokens match' do
        expect(site_filters[:included_sites]).to contain_exactly(
          have_attributes(domain_name: 'gov', url_path: nil)
        )
      end
    end

    context 'when the query includes a site path with a trailing slash' do
      let(:query) { 'gobierno site:www.usa.gov/espanol/' }

      it 'normalizes the path without a trailing slash' do
        expect(site_filters[:included_sites]).to contain_exactly(
          have_attributes(domain_name: 'www.usa.gov', url_path: '/espanol')
        )
      end
    end
  end
end
