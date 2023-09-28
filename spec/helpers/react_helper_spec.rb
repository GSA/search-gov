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

    context 'when affiliate has alert with text and title' do
      it 'sets alert to contain both text and title' do
        alert_data = { text: 'Alert text', title: 'Alert title' }
        affiliate.build_alert(alert_data)
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_including(alert: alert_data)
        )
      end
    end

    context 'when affiliate has alert with only title' do
      it 'sets alert to contain only title' do
        alert_data = { text: '', title: 'Alert title' }
        affiliate.build_alert(alert_data)
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_including(alert: alert_data)
        )
      end
    end

    context 'when affiliate has alert with only text' do
      it 'sets alert to contain only text' do
        alert_data = { text: 'Alert text', title: '' }
        affiliate.build_alert(alert_data)
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_including(alert: alert_data)
        )
      end
    end

    context 'when affiliate has no alert' do
      before do
        affiliate.alert = nil
      end

      it 'sets alert to nil in the data hash' do
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

    context 'with an affiliate with type ahead suggestions' do
      before do
        SaytSuggestion.create!(phrase: 'chocolate bar', affiliate: affiliate)
        ElasticSaytSuggestion.commit
        search.run
      end

      it 'sends suggestion to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, true, affiliate)

        related_search = {
          label: '<strong>chocolate</strong> bar',
          link: '/search?affiliate=usagov&query=chocolate+bar'
        }

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(relatedSearches: [related_search]))
      end
    end

    context 'when an affiliate has news label and news items' do
      let(:results) do
        [ 
          { feedName: "Biographies", publishedAt: "27 days ago", title: "Rear Admiral Robert T. Clark"},
          { feedName: "Biographies2", publishedAt: "20 days ago", title: "Rear Admiral Robert T. Clark2"}
        ]
      end
      let(:news_about_query) { 'News about chocolate' }
      let(:news_label) { { newsAboutQuery: news_about_query, results: results } }

      before do
        allow(helper).to receive(:news_about_query).and_return(news_about_query)
        allow(helper).to receive(:news_items_results).and_return(results)
      end

      it 'returns the correct news label hash' do
        helper.search_results_layout(search, {}, vertical, affiliate)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_including(newsLabel: news_label)
        )
      end
    end
  end
end
