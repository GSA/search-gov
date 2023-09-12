# frozen_string_literal: true

require 'spec_helper'

describe ReactHelper do
  describe '#search_results_layout' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:search) { WebSearch.new(query: 'chocolate', affiliate: affiliate) }
    let(:vertical) { 'vertical_nav' }

    before do
      allow(helper).to receive(:react_component)
    end

    context 'when an affiliate has connections' do
      let(:related_sites) do
        [{
          label: 'power',
          link: 'http://test.host/search?affiliate=noaa.gov&query=chocolate'
        }]
      end

      it 'sends related sites label and link to SearchResultsLayout component' do
        affiliate.connections.create(connected_affiliate: affiliates(:power_affiliate), label: :power)

        helper.search_results_layout(search, {}, true, affiliate)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(relatedSites: related_sites))
      end
    end

    context 'when an affiliate has no connections' do
      it 'does not send related sites to the SearchResultsLayout' do
        helper.search_results_layout(search, {}, true, affiliate)

        expect(helper).not_to have_received(:react_component).
          with('SearchResultsLayout', hash_including(:relatedSites))
      end
    end

    context 'when alert is present and has text and title' do
      let(:alert) { instance_double(Alert, text: 'alert_title', title: 'alert_title') }

      it 'includes alert and has text and title' do
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_excluding(:alert)
        )
      end
    end

    context 'when alert is present but text is blank' do
      let(:alert) { instance_double(Alert, text: '', title: 'alert_title') }

      it 'excludes alert from data' do
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_excluding(:alert)
        )
      end
    end

    context 'when alert is present but title is blank' do
      let(:alert) { instance_double(Alert, text: 'alert_title', title: '') }

      it 'excludes alert from data' do
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_excluding(:alert)
        )
      end
    end

    context 'when alert is not present' do
      let(:alert) { nil }

      it 'excludes alert from data' do
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_excluding(:alert)
        )
      end
    end

    context 'with an affiliate with navigations' do
      let(:navigation_links) do
        [
          { active: false, label: 'Usa Gov Blog', link: '/search/news?channel=321734936&query=chocolate' },
          { active: false, label: 'USAGov Collection', link: '/search/docs?dc=40842210&query=chocolate' }
        ]
      end

      it 'sends links to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, true, affiliate)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(navigationLinks: navigation_links))
      end
    end
  end
end
