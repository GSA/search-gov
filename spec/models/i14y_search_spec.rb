# frozen_string_literal: true

describe I14ySearch do
  subject(:i14y_search) { described_class.new(filterable_search_options) }

  let(:affiliate) { affiliates(:i14y_affiliate) }
  let(:highlighting) { true }
  let(:query) { 'marketplase' }
  let(:filterable_search_options) do
    { affiliate: affiliate,
      enable_highlighting: highlighting,
      limit: 20,
      offset: 0,
      query: query }
  end

  describe '#initialize' do
    let(:query) { 'electro coagulation' }

    it_behaves_like 'an initialized filterable search'

    context 'when options does not include sort_by' do
      its(:sort_by_relevance?) { is_expected.to be true }
      its(:sort) { is_expected.to be_nil }
    end

    context 'when facet filters are present' do
      subject(:i14y_search) do
        described_class.new filterable_search_options.
          merge(tags: 'tag from params')
      end

      its(:tags) { is_expected.to eq('tag from params') }
    end
  end

  context 'when results are available' do
    before { i14y_search.run }

    its(:startrecord) { is_expected.to eq(1) }
    its(:endrecord) { is_expected.to eq(20) }
    its(:total) { is_expected.to eq(270) }
    its(:spelling_suggestion) { is_expected.to eq('marketplace') }
    its(:aggregations) { is_expected.to match(array_including(hash_including('content_type'), hash_including('changed'))) }
    its('results.first.title') { is_expected.to eq('Marketplace') }
    its('results.first.link') { is_expected.to eq('https://www.healthcare.gov/glossary/marketplace') }
    its('results.first.description') { is_expected.to eq('See Health Insurance Marketplace...More info on Health Insurance Marketplace') }
    its('results.first.body') { is_expected.to eq('More info on Health Insurance Marketplace') }
  end

  context 'when sort_by=date' do
    let(:i14y_search) do
      described_class.new(filterable_search_options.
        merge(sort_by: 'date'))
    end

    before { allow(I14yCollections).to receive(:search) }

    it 'searches I14y with the appropriate params' do
      i14y_search.run
      expect(I14yCollections).to have_received(:search).with(hash_including(sort_by_date: 1))
    end
  end

  context 'when include_facets is true' do
    let(:i14y_search) do
      described_class.new(filterable_search_options.
        merge(include_facets: 'true'))
    end
    let(:query) { 'testing tag filters' }

    before { allow(I14yCollections).to receive(:search) }

    it 'requests facet fields be included in the search' do
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(include: 'title,path,audience,changed,content_type,' \
                                     'created,mime_type,searchgov_custom1,' \
                                     'searchgov_custom2,searchgov_custom3,tags'))
    end
  end

  context 'when tag filters are present' do
    let(:query) { 'testing tag filters' }

    before { allow(I14yCollections).to receive(:search) }

    context 'when only affiliate-set tag filters are present' do
      let(:affiliate) { affiliates(:basic_affiliate) }

      it 'searches I14y with the appropriate filter params' do
        i14y_search.run
        expect(I14yCollections).to have_received(:search).
          with(hash_including(ignore_tags: 'no way,nope',
                              tags: 'important,must have'))
      end
    end

    context 'when only tag filter query params are present' do
      let(:affiliate) { affiliates(:searchgov_affiliate) }
      let(:i14y_search) do
        described_class.new(filterable_search_options.
          merge(tags: 'tag from params'))
      end

      it 'searches I14y with the appropriate filter params' do
        i14y_search.run
        expect(I14yCollections).to have_received(:search).
          with(hash_including(tags: 'tag from params'))
      end
    end

    context 'when both affiliate-set and query param tag filters are present' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:i14y_search) do
        described_class.new(filterable_search_options.
          merge(tags: 'tag from params'))
      end

      it 'searches I14y with all relevant tags params' do
        i14y_search.run
        expect(I14yCollections).to have_received(:search).
          with(hash_including(ignore_tags: 'no way,nope',
                              tags: 'important,must have,tag from params'))
      end
    end
  end

  context 'when sort_by=date and tbs is specified' do
    let(:i14y_search) do
      described_class.new(filterable_search_options.
        merge(sort_by: 'date',
              tbs: 'm'))
    end

    before { allow(I14yCollections).to receive(:search) }

    it 'searches I14y with the appropriate params' do
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(sort_by_date: 1, min_timestamp: 1.send(:month).ago.beginning_of_day))
    end
  end

  context 'when sort_by=date and since_date and until_date are specified' do
    let(:i14y_search) do
      described_class.new(filterable_search_options.
        merge(sort_by: 'date',
              since_date: '07/28/2015',
              until_date: '09/28/2015'))
    end

    before { allow(I14yCollections).to receive(:search) }

    it 'searches I14y with the appropriate params' do
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(sort_by_date: 1,
                            min_timestamp: DateTime.parse('07/28/2015').beginning_of_day,
                            max_timestamp: DateTime.parse('09/28/2015T23:59:59.999999999Z')))
    end
  end

  context 'when enable_highlighting is false' do
    let(:highlighting) { false }

    before { i14y_search.run }

    its('results.first.title') { is_expected.to eq('Marketplace') }
    its('results.first.link') { is_expected.to eq('https://www.healthcare.gov/glossary/marketplace') }
    its('results.first.description') { is_expected.to eq('See Health Insurance Marketplace...More info on Health Insurance Marketplace') }
    its('results.first.body') { is_expected.to eq('More info on Health Insurance Marketplace') }
  end

  context 'when a site limit is specified' do
    let(:i14y_search) do
      described_class.new(filterable_search_options.
        merge(site_limits: 'http://nih.gov/foo'))
    end

    before { affiliate.site_domains.create!(domain: 'nih.gov') }

    it 'passes the site limit to i14y with out http/https' do
      allow(I14yCollections).to receive(:search)
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(query: 'marketplase site:nih.gov/foo'))
    end

    it 'sets matching site limits' do
      expect(i14y_search.matching_site_limits).to eq ['nih.gov/foo']
    end
  end

  context 'when multiple site limits are specified' do
    let(:i14y_search) do
      described_class.new(filterable_search_options.
        merge(site_limits: 'http://nih.gov/foo https://nih.gov/bar'))
    end

    before { affiliate.site_domains.create!(domain: 'nih.gov') }

    it 'passes the site limits to i14y with out http/https' do
      allow(I14yCollections).to receive(:search)
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(query: 'marketplase site:nih.gov/bar site:nih.gov/foo'))
    end

    it 'sets matching site limits' do
      expect(i14y_search.matching_site_limits).
        to match(array_including('nih.gov/foo', 'nih.gov/bar'))
    end
  end

  context 'when there is some problem with the i14y client' do
    before do
      allow(I14yCollections).to receive(:search).and_raise Faraday::ClientError.new(Exception.new('problem'))
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the error' do
      i14y_search.run
      expect(Rails.logger).to have_received(:error).with(/I14y search problem/)
    end
  end

  context 'when the affiliate has specified site domains' do
    let(:affiliate) { affiliates(:basic_affiliate) }

    before { allow(I14yCollections).to receive(:search) }

    it 'searches within those domains' do
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(query: 'marketplase site:nps.gov'))
    end
  end

  context 'when the affiliate has excluded domains' do
    let(:affiliate) { affiliates(:power_affiliate) }

    before { affiliate.excluded_domains.create(domain: 'excluded.gov') }

    it 'excludes those domains' do
      allow(I14yCollections).to receive(:search)
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(query: 'marketplase -site:excluded.gov'))
    end
  end

  describe 'handles' do
    context 'when the affiliate is using SearchGov as a search engine' do
      before do
        allow(affiliate).to receive(:search_engine).and_return('SearchGov')
        allow(I14yCollections).to receive(:search)
      end

      context 'when they have existing I14y drawers' do
        it 'searches the searchgov drawer plus their existing drawers' do
          i14y_search.run
          expect(I14yCollections).to have_received(:search).
            with(hash_including(handles: 'one,two,searchgov'))
        end

        context 'when they do not receive i14y results' do
          before { allow(affiliate).to receive(:gets_i14y_results).and_return(false) }

          it 'searches only the searchgov drawer' do
            i14y_search.run
            expect(I14yCollections).to have_received(:search).
              with(hash_including(handles: 'searchgov'))
          end
        end
      end

      context 'when the affiliate does not have i14y drawers' do
        let(:affiliate) { affiliates(:basic_affiliate) }

        it 'searches just the searchgov drawer' do
          i14y_search.run
          expect(I14yCollections).to have_received(:search).
            with(hash_including(handles: 'searchgov'))
        end
      end
    end

    # This covers the scenario where a non-i14y-, non-searchgov-affiliate needs to search
    # the searchgov drawer for deep collection results
    %w[BingV6 BingV7].each do |search_engine|
      context "when the affiliate is using #{search_engine} as a search engine" do
        before do
          allow(affiliate).to receive(:search_engine).and_return(search_engine)
          allow(I14yCollections).to receive(:search)
        end

        context 'when they do not receive i14y results' do
          before { allow(affiliate).to receive(:gets_i14y_results).and_return(false) }

          it 'searches the searchgov drawer' do
            i14y_search.run
            expect(I14yCollections).to have_received(:search).
              with(hash_including(handles: 'searchgov'))
          end
        end
      end
    end
  end
end
