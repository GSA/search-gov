require 'spec_helper'

describe ImageSearch do
  fixtures :affiliates

  let(:cr_affiliate) { affiliates(:bing_image_search_enabled_affiliate) }
  let(:non_cr_affiliate) { affiliates(:usagov_affiliate) }

  describe '#run' do
    context 'when is_bing_image_search_enabled? is false' do
      let(:search) { ImageSearch.new(affiliate: non_cr_affiliate, query: 'white house') }
      let!(:odie_image_search) do
        OdieImageSearch.new affiliate: non_cr_affiliate,
                            page: 1,
                            per_page: 20,
                            query: 'gov'
      end

      before do
        OdieImageSearch.should_receive(:new).and_return(odie_image_search)
        odie_image_search.should_receive(:run)
      end

      context 'when OdieImageSearch results are present' do
        before do
          results = [mock('item'), mock('item')]
          odie_image_search.stub(:results).and_return(results)
        end

        it 'logs SERP impressions with FLICKR' do
          QueryImpression.should_receive(:log).with(:image, 'usagov', 'white house', %w(FLICKR))
          search.run
        end
      end

      context 'when OdieImageSearch results are not present' do
        before { odie_image_search.stub(:results).and_return([]) }

        it 'logs SERP impressions with FLICKR' do
          QueryImpression.should_receive(:log).with(:image, 'usagov', 'white house', [])
          search.run
        end
      end
    end

    context 'when is_bing_image_search_enabled? is true' do
      let(:search) { ImageSearch.new(affiliate: cr_affiliate, query: 'white house') }

      let!(:odie_image_search) do
        OdieImageSearch.new affiliate: cr_affiliate,
                            page: 1,
                            per_page: 20,
                            query: 'white house'
      end

      let!(:bing_image_search_adapter) do
        SearchEngineAdapter.new BingImageSearch,
                                affiliate: cr_affiliate,
                                page: 1,
                                per_page: 20,
                                query: 'white house'
      end

      before do
        OdieImageSearch.should_receive(:new).and_return(odie_image_search)
        odie_image_search.should_receive(:run)
        odie_image_search.stub(:results).and_return([])

        SearchEngineAdapter.should_receive(:new).and_return(bing_image_search_adapter)
      end

      context 'when BingImageSearch results are present' do
        before do
          results = [mock('item'), mock('item')]
          bing_image_search_adapter.stub(:results).and_return(results)
        end

        it 'logs SERP impressions with FLICKR' do
          QueryImpression.should_receive(:log).with(:image, 'cr.images.gov', 'white house', %w(IMAG))
          search.run
        end
      end

      context 'when BingImageSearch results are not present' do
        before { bing_image_search_adapter.stub(:results).and_return([]) }

        it 'logs SERP impressions with FLICKR' do
          QueryImpression.should_receive(:log).with(:image, 'cr.images.gov', 'white house', [])
          search.run
        end
      end
    end
  end
end
