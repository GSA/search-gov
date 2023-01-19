# frozen_string_literal: true

require 'spec_helper'

describe I14ySearch do
  let(:affiliate) { affiliates(:i14y_affiliate) }
  let(:i14y_search) { described_class.new(affiliate: affiliate, query: 'marketplase') }

  describe '#initialize' do
    let(:filterable_search_options) do
      { affiliate: affiliate,
        enable_highlighting: true,
        limit: 20,
        offset: 0,
        query: 'electro coagulation' }
    end

    it_behaves_like 'an initialized filterable search'

    context 'when options does not include sort_by' do
      subject(:test_search) { described_class.new(filterable_search_options) }

      its(:sort_by_relevance?) { is_expected.to be true }
      its(:sort) { is_expected.to be_nil }
    end

    context 'when facet filters are present' do
      subject(:test_search) do
        described_class.new filterable_search_options.
          merge(tags: 'tag from params')
      end

      its(:tags) { is_expected.to eq('tag from params') }
    end
  end

  context 'when results are available' do
    let(:i14y_search) { described_class.new(affiliate: affiliate, query: 'marketplase', per_page: 20) }

    it 'returns a response' do
      i14y_search.run
      expect(i14y_search.startrecord).to eq(1)
      expect(i14y_search.endrecord).to eq(20)
      expect(i14y_search.total).to eq(270)
      expect(i14y_search.spelling_suggestion).to eq('marketplace')
      expect(i14y_search.aggregations).to match(array_including(hash_including('content_type')))
      expect(i14y_search.aggregations).to match(array_including(hash_including('changed')))
      first = i14y_search.results.first
      expect(first.title).to eq('Marketplace')
      expect(first.link).to eq('https://www.healthcare.gov/glossary/marketplace')
      expect(first.description).to eq('See Health Insurance Marketplace...More info on Health Insurance Marketplace')
      expect(first.body).to eq('More info on Health Insurance Marketplace')
    end
  end

  context 'when sort_by=date' do
    let(:i14y_search) do
      described_class.new(affiliate: affiliate,
                          sort_by: 'date',
                          per_page: 20,
                          query: 'marketplase')
    end

    before { allow(I14yCollections).to receive(:search) }

    it 'searches I14y with the appropriate params' do
      i14y_search.run
      expect(I14yCollections).to have_received(:search).with(hash_including(sort_by_date: 1))
    end
  end

  context 'when include_facets is true' do
    let(:search_params) { { affiliate: affiliate, per_page: 20, query: 'testing tag filters', include_facets: 'true' } }
    let(:i14y_search) { described_class.new(search_params) }

    before { allow(I14yCollections).to receive(:search) }

    it 'requests facet fields be included in the search' do
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(include: 'title,path,audience,changed,content_type,'\
                                     'created,mime_type,searchgov_custom1,'\
                                     'searchgov_custom2,searchgov_custom3,tags'))
    end
  end

  context 'when tag filters are present' do
    let(:search_params) { { affiliate: affiliate, per_page: 20, query: 'testing tag filters' } }
    let(:i14y_search) { described_class.new(search_params) }

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
      let(:i14y_search) { described_class.new(search_params.merge(tags: 'tag from params')) }

      it 'searches I14y with the appropriate filter params' do
        i14y_search.run
        expect(I14yCollections).to have_received(:search).
          with(hash_including(tags: 'tag from params'))
      end
    end

    context 'when both affiliate-set and query param tag filters are present' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:i14y_search) { described_class.new(search_params.merge(tags: 'tag from params')) }

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
      described_class.new(affiliate: affiliate,
                          sort_by: 'date',
                          tbs: 'm',
                          per_page: 20,
                          query: 'marketplase')
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
      described_class.new(affiliate: affiliate,
                          sort_by: 'date',
                          since_date: '07/28/2015',
                          until_date: '09/28/2015',
                          per_page: 20,
                          query: 'marketplase')
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
    let(:i14y_search) do
      described_class.new(affiliate: affiliate,
                          enable_highlighting: false,
                          per_page: 20,
                          query: 'marketplase')
    end

    it 'returns non highlighted results' do
      i14y_search.run
      first = i14y_search.results.first
      expect(first.title).to eq('Marketplace')
      expect(first.link).to eq('https://www.healthcare.gov/glossary/marketplace')
      expect(first.description).to eq('See Health Insurance Marketplace...More info on Health Insurance Marketplace')
      expect(first.body).to eq('More info on Health Insurance Marketplace')
    end
  end

  context 'when a site limit is specified' do
    let!(:site_domains) { affiliate.site_domains.create!(domain: 'nih.gov') }
    let(:i14y_search) do
      described_class.new(affiliate: affiliate,
                          site_limits: 'http://nih.gov/foo',
                          query: 'marketplase')
    end

    it 'passes the sitelimits to i14y with out http/https' do
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
    let!(:site_domains) { affiliate.site_domains.create!(domain: 'nih.gov') }
    let(:i14y_search) do
      described_class.new(
        affiliate: affiliate,
        site_limits: 'http://nih.gov/foo https://nih.gov/bar',
        query: 'marketplase'
      )
    end

    it 'passes the sitelimits to i14y with out http/https' do
      allow(I14yCollections).to receive(:search)
      i14y_search.run
      expect(I14yCollections).to have_received(:search).
        with(hash_including(query: 'marketplase site:nih.gov/bar site:nih.gov/foo'))
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
