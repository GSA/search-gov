# frozen_string_literal: true

require 'spec_helper'

describe ReactHelper do
  describe '#search_results_layout' do
    context 'when an affiliate has connections' do
      let(:affiliate) { affiliates(:usagov_affiliate) }
      let(:search)    { WebSearch.new(query: 'chocolate', affiliate: affiliate) }
      let(:related_sites) do
        [{
          label: 'power',
          link: 'http://test.host/search?affiliate=noaa.gov&query=chocolate'
        }]
      end

      it 'sends related sites label and link to SearchResultsLayout component' do
        allow(helper).to receive(:react_component)
        affiliate.connections.create(connected_affiliate: affiliates(:power_affiliate), label: :power)

        helper.search_results_layout(search, {}, true, affiliate)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(relatedSites: related_sites))
      end
    end
  end
end
