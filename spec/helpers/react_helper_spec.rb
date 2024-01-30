# frozen_string_literal: true

require 'spec_helper'

describe ReactHelper do
  describe '#search_results_layout' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:vertical) { 'vertical_nav' }
    let(:search) { WebSearch.new(query: 'chocolate', affiliate: affiliate) }
    let(:search_options) { {} }

    before do
      allow(helper).to receive(:react_component)
    end

    context 'when an affiliate has primary header links' do
      before do
        3.times do |i|
          Link.create!(position: i,
                       title: "Link #{i}",
                       url: "https://link_#{i}.gov",
                       type: PrimaryHeaderLink,
                       affiliate_id: affiliate.id)
        end
      end

      it 'sends the primary header links array to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(primaryHeaderLinks: [
                                                       { title: 'Link 0', url: 'https://link_0.gov' },
                                                       { title: 'Link 1', url: 'https://link_1.gov' },
                                                       { title: 'Link 2', url: 'https://link_2.gov' }
                                                     ]))
      end
    end

    context 'when an affiliate has secondary header links' do
      before do
        3.times do |i|
          Link.create!(position: i,
                       title: "Link #{i}",
                       url: "https://link_#{i}.gov",
                       type: SecondaryHeaderLink,
                       affiliate_id: affiliate.id)
        end
      end

      it 'sends the secondary header links array to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(secondaryHeaderLinks: [
                                                       { title: 'Link 0', url: 'https://link_0.gov' },
                                                       { title: 'Link 1', url: 'https://link_1.gov' },
                                                       { title: 'Link 2', url: 'https://link_2.gov' }
                                                     ]))
      end
    end

    context 'when an affiliate has footer links' do
      before do
        3.times do |i|
          Link.create!(position: i,
                       title: "Link #{i}",
                       url: "https://link_#{i}.gov",
                       type: FooterLink,
                       affiliate_id: affiliate.id)
        end
      end

      it 'sends the footer links array to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(footerLinks: [
                                                       { title: 'Link 0', url: 'https://link_0.gov' },
                                                       { title: 'Link 1', url: 'https://link_1.gov' },
                                                       { title: 'Link 2', url: 'https://link_2.gov' }
                                                     ]))
      end
    end

    context 'when an affiliate has identifier content' do
      before do
        affiliate.update!({ identifier_domain_name: 'Example Domain Name',
                            parent_agency_name: 'My Agency',
                            parent_agency_link: 'https://agency.gov',
                            header_logo: nil })
        allow(affiliate).to receive(:identifier_logo_blob).and_return(nil)
      end

      let(:identifier_content) do
        {
          domainName: 'Example Domain Name',
          parentAgencyName: 'My Agency',
          parentAgencyLink: 'https://agency.gov',
          logoAltText: nil,
          logoUrl: nil
        }
      end

      it 'sends identifier content to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(identifierContent: identifier_content))
      end
    end

    context 'when an affiliate has identifier content with a logo' do
      before do
        affiliate.update!({ identifier_domain_name: 'Example Domain Name',
                            parent_agency_name: 'My Agency',
                            parent_agency_link: 'https://agency.gov',
                            header_logo: nil })
        allow(affiliate).to receive(:identifier_logo).and_return('https://www.search.gov')
      end

      let(:identifier_content) do
        {
          domainName: 'Example Domain Name',
          parentAgencyName: 'My Agency',
          parentAgencyLink: 'https://agency.gov',
          logoAltText: nil,
          logoUrl: 'https://www.search.gov'
        }
      end

      it 'sends identifier content to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(identifierContent: identifier_content))
      end
    end

    context 'when an affiliate has identifier links' do
      before do
        3.times do |i|
          Link.create!(position: i,
                       title: "Link #{i}",
                       url: "https://link_#{i}.gov",
                       type: IdentifierLink,
                       affiliate_id: affiliate.id)
        end
      end

      it 'sends the identifier links array to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(identifierLinks: [
                                                       { title: 'Link 0', url: 'https://link_0.gov' },
                                                       { title: 'Link 1', url: 'https://link_1.gov' },
                                                       { title: 'Link 2', url: 'https://link_2.gov' }
                                                     ]))
      end
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

        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(relatedSites: related_sites))
      end
    end

    context 'when an affiliate has no connections' do
      it 'does not send related sites to the SearchResultsLayout' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).not_to have_received(:react_component).
          with('SearchResultsLayout', hash_including(:relatedSites))
      end
    end

    context 'when affiliate has an active alert with text and title' do
      it 'sets alert to contain both text and title' do
        alert_data = { text: 'Alert text', title: 'Alert title' }
        affiliate.build_alert(alert_data.merge(status: 'Active'))
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_including(alert: alert_data)
        )
      end
    end

    context 'when affiliate has an inactive alert with text and title' do
      it 'sets alert to contain only title' do
        alert_data = { text: 'Alert text', title: 'Alert title', status: 'Inactive' }
        affiliate.build_alert(alert_data)
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_excluding(:alert)
        )
      end
    end

    context 'when affiliate has no alert' do
      before do
        affiliate.alert = nil
      end

      it 'sets alert to nil in the data hash' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_excluding(:alert)
        )
      end
    end

    context 'with an affiliate with navigations' do
      let(:navigation_links) do
        [
          { active: true,  facet: 'Default', label: 'search', url: '/search?query=chocolate' },
          { active: false, facet: 'RSS', label: 'Usa Gov Blog', url: '/search/news?channel=321734936&query=chocolate' },
          { active: false, facet: 'DocumentCollection', label: 'USAGov Collection', url: '/search/docs?dc=40842210&query=chocolate' }
        ]
      end

      it 'sends links to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(navigationLinks: navigation_links))
      end
    end

    context 'with an affiliate with type ahead suggestions' do
      before do
        allow(search).to receive(:govbox_set).and_return(nil)
        SaytSuggestion.create!(phrase: 'chocolate bar', affiliate: affiliate)
        ElasticSaytSuggestion.commit
        search.run
      end

      it 'sends suggestion to SearchResultsLayout component' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        related_search = {
          label: '<strong>chocolate</strong> bar',
          link: '/search?affiliate=usagov&query=chocolate+bar'
        }

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(relatedSearches: [related_search]))
      end
    end

    context 'when an affiliate has news label and news items' do
      let(:twelve_years_ago) { DateTime.now - 12.years }
      let(:news_items) do
        instance_double(ElasticNewsItemResults,
                        results: [
                          mock_model(NewsItem, title: 'GSA News Item 1', description: true, link: 'http://search.gov/1', published_at: twelve_years_ago, rss_feed_url_id: rss_feed.rss_feed_urls.first.id),
                          mock_model(NewsItem, title: 'GSA News Item 2', description: true, link: 'http://search.gov/2', published_at: twelve_years_ago, rss_feed_url_id: rss_feed.rss_feed_urls.first.id)
                        ])
      end
      let(:rss_feed) do
        rss_feeds(:usagov_blog).tap do |rss_feed|
          rss_feed.rss_feed_urls = [rss_feed_urls(:white_house_blog_url)]
        end
      end
      let(:news_label) do
        {
          newsAboutQuery: 'RSSGovbox about chocolate',
          results: [
            { title: 'GSA News Item 1', feedName: 'Usa Gov Blog', publishedAt: 'about 12 years ago' },
            { title: 'GSA News Item 2', feedName: 'Usa Gov Blog', publishedAt: 'about 12 years ago' }
          ]
        }
      end

      before do
        allow(search).to receive(:news_items).and_return(news_items)
      end

      it 'returns the correct news label hash' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)
        expect(helper).to have_received(:react_component).with(
          'SearchResultsLayout',
          hash_including(newsLabel: news_label)
        )
      end
    end

    context 'when search contains a spelling suggestion' do
      before do
        allow(search).to receive(:spelling_suggestion).and_return('chalkcolate')
      end

      it 'returns a spelling suggestion hash' do
        helper.search_results_layout(search, {}, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(spellingSuggestion:
          {
            original: '<a href="/search?affiliate=usagov&amp;query=%2Bchocolate">chocolate</a>',
            suggested: '<a href="/search?affiliate=usagov&amp;query=chalkcolate">chalkcolate</a>'
          }))
      end

      context 'when a sitelimit is provided' do
        let(:search_options) { { site_limits: 'usa.gov' } }

        it 'persists the sitelimit in the spelling suggestion hash' do
          helper.search_results_layout(search, {}, vertical, affiliate, search_options)

          expect(helper).to have_received(:react_component).
            with('SearchResultsLayout', hash_including(spellingSuggestion:
            {
              original: '<a href="/search?affiliate=usagov&amp;query=%2Bchocolate&amp;sitelimit=usa.gov">chocolate</a>',
              suggested: '<a href="/search?affiliate=usagov&amp;query=chalkcolate&amp;sitelimit=usa.gov">chalkcolate</a>'
            }))
        end
      end
    end

    describe '#agency_name' do
      context 'when affiliate has an agency abbreviation or name' do
        it 'sets agency to contain abbreviation or name' do
          affiliate.build_agency({ abbreviation: nil, name: 'Department of Energy' })
          helper.search_results_layout(search, {}, vertical, affiliate, search_options)
          expect(helper).to have_received(:react_component).with(
            'SearchResultsLayout',
            hash_including(agencyName: 'Department of Energy')
          )
        end
      end

      context 'when affiliate has no agency' do
        before do
          affiliate.agency = nil
        end

        it 'sets agency to nil in the data hash' do
          helper.search_results_layout(search, {}, vertical, affiliate, search_options)
          expect(helper).to have_received(:react_component).with(
            'SearchResultsLayout',
            hash_excluding(:agencyName)
          )
        end
      end
    end

    context 'when search contains a sitelimit' do
      it 'returns a sitelimit hash' do
        helper.search_results_layout(search, { sitelimit: 'usa.gov' }, vertical, affiliate, search_options)

        expect(helper).to have_received(:react_component).
          with('SearchResultsLayout', hash_including(sitelimit:
          {
            sitelimit: 'usa.gov',
            url: '/search?affiliate=usagov&query=chocolate'
          }))
      end
    end

    describe '#govbox_set_data' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:geoip_info) { instance_double(GeoIP::City, location_name: 'Flemington, New Jersey, United States') }
      let(:govbox_set) { GovboxSet.new('foo', affiliate, geoip_info) }
      let(:agency) { agencies(:irs) }
      let(:federal_register_agency) { federal_register_agencies(:fr_irs) }
      let(:federal_register_document) do
        FederalRegisterDocument.new(
          document_number: 1,
          title: 'Test FRD',
          abstract: 'This is a test FRD.',
          html_url: 'http://www.federalregister.gov/articles/2016/05/11/2016-10932/unsuccessful-work',
          document_type: 'Proposed Rule',
          start_page: 2,
          end_page: 5,
          page_length: 4,
          publication_date: Date.new(2020, 1, 2, 3),
          comments_close_on: Date.new(2024, 4, 5, 6)
        )
      end
      let(:federal_agency_names) { ['GSA'] }
      let(:results) { instance_double(ElasticFederalRegisterDocumentResults, total: 1, results: [federal_register_document]) }

      before do
        allow(affiliate).to receive_messages(is_federal_register_document_govbox_enabled?: true, display_created_date_on_search_results?: false, agency: agency)
        allow(federal_register_document).to receive(:contributing_agency_names).and_return(federal_agency_names)
        allow(ElasticFederalRegisterDocument).to receive(:search_for).and_return(results)
        allow(search).to receive(:govbox_set).and_return(govbox_set)
      end

      context 'when display_created_date_on_search_results is false' do
        before do
          allow(affiliate).to receive(:search_engine).and_return('SearchGov')
        end

        it 'filters out the created date from federal_register_documents results' do
          search_var = helper.send(:govbox_set_data, search)
          expect(search_var.as_json['federalRegisterDocuments'].first).not_to include('publication_date')
        end
      end
    end
  end
end
