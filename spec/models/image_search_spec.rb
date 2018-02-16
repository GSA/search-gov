require 'spec_helper'

describe ImageSearch do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe ".new" do
    context 'when affiliate has no social media for images' do
      before do
        allow(affiliate).to receive(:has_no_social_image_feeds?).and_return true
      end

      it 'should use commercial results instead of Oasis' do
        image_search = ImageSearch.new(affiliate: affiliate, query: "some query")
        expect(image_search.uses_cr).to be true
      end
    end
  end

  describe "#run" do
    context 'when Oasis results are blank AND we are on page 1 AND no commercial results override is set AND Bing image results are enabled' do
      let(:image_search) { ImageSearch.new(affiliate: affiliate, query: "lsdkjflskjflskjdf") }
      let(:search_engine_adapter) { double(SearchEngineAdapter, results: nil) }

      before do
        affiliate.update_attribute(:is_bing_image_search_enabled, true)
        allow(affiliate).to receive(:has_no_social_image_feeds?).and_return false
      end

      context 'when search_engine is BingV6' do
        before { affiliate.search_engine = 'BingV6' }

        it 'should perform a Bing image search' do
          expect(SearchEngineAdapter).to receive(:new).
            with(BingV6ImageSearch,
                 hash_including(affiliate: affiliate,
                                page: 1,
                                per_page: 20,
                                query: 'lsdkjflskjflskjdf')).
            and_return(search_engine_adapter)
          expect(search_engine_adapter).to receive(:run)
          image_search.run
        end
      end

      context 'when search_engine is Azure' do
        before { affiliate.search_engine = 'Azure' }

        it 'should perform an Azure image search' do
          expect(SearchEngineAdapter).to receive(:new).
            with(HostedAzureImageEngine,
                 hash_including(affiliate: affiliate,
                                page: 1,
                                per_page: 20,
                                query: 'lsdkjflskjflskjdf')).
            and_return(search_engine_adapter)
          expect(search_engine_adapter).to receive(:run)
          image_search.run
        end
      end

      context 'when search_engine is SearchGov' do
        before { affiliate.search_engine = 'SearchGov' }

        it 'should perform a Bing V6 image search' do
          expect(SearchEngineAdapter).to receive(:new).
            with(BingV6ImageSearch,
                 hash_including(affiliate: affiliate,
                                page: 1,
                                per_page: 20,
                                query: 'lsdkjflskjflskjdf')).
            and_return(search_engine_adapter)
          expect(search_engine_adapter).to receive(:run)
          image_search.run
        end
      end
    end
  end

  describe '#spelling_suggestion' do
    subject(:image_search) { ImageSearch.new(affiliate: affiliate, query: "lsdkjflskjflskjdf") }
    let(:search_engine_adapter) { double(SearchEngineAdapter, default_module_tag: 'module_tag', results: [], spelling_suggestion: 'spel') }
    before do
      allow(SuggestionBlock).to receive(:exists?).and_return(suggestion_block_exists)
      allow(SearchEngineAdapter).to receive(:new).and_return(search_engine_adapter)
      allow(search_engine_adapter).to receive(:run)
    end

    context 'when no suggestion block exists for the given query' do
      let(:suggestion_block_exists) { false }

      it 'returns the search engine spelling suggestion' do
        image_search.run
        expect(image_search.spelling_suggestion).to eq('spel')
      end
    end

    context 'when a suggestion block exists for the given query' do
      let (:suggestion_block_exists) { true }

      it 'returns nil' do
        image_search.run
        expect(image_search.spelling_suggestion).to be_nil
      end
    end
  end
end
