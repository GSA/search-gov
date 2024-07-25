require 'spec_helper'

describe ImageSearch do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe '.new' do
    context 'when affiliate has no social media for images' do
      before do
        allow(affiliate).to receive(:has_no_social_image_feeds?).and_return true
      end

      it 'uses commercial results instead of Oasis' do
        image_search = described_class.new(affiliate:, query: 'some query')
        expect(image_search.uses_cr).to be true
      end
    end
  end

  describe '#diagnostics' do
    subject(:image_search) do
      described_class.new(affiliate:, query: 'corgis', cr: use_commercial_results)
    end

    let(:use_commercial_results) { nil }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:search_engine) { nil }
    let(:underlying_search_instance) { instance_double(OdieImageSearch) }

    before do
      allow(affiliate).to receive_messages(search_engine:, has_no_social_image_feeds?: false)
      allow(underlying_search_instance).to receive(:diagnostics).and_return(:underlying_diagnostics)
      allow(underlying_search_class).to receive(:new).and_return(underlying_search_instance)
    end

    context 'when commercial search results are specified' do
      let(:use_commercial_results) { 'true' }

      # context 'when the affiliate search_engine is BingV7' do
      #   let(:search_engine) { 'BingV7' }
      #   let(:underlying_search_class) { SearchEngineAdapter }

      #   it 'delegates to SearchEngineAdapter#diagnostics' do
      #     expect(image_search.diagnostics).to be(:underlying_diagnostics)
      #   end
      # end

      context "when the affiliate's search_engine is SearchGov" do
        let(:search_engine) { 'SearchGov' }
        let(:underlying_search_class) { OdieImageSearch }

        it 'delegates to OdieImageSearch#diagnostics' do
          expect(image_search.diagnostics).to be(:underlying_diagnostics)
        end
      end
    end

    context 'when commercial search results are not specified' do
      let(:use_commercial_results) { 'untrue' }
      let(:underlying_search_class) { OdieImageSearch }

      it 'delegates to OdieImageSearch#diagnostics' do
        expect(image_search.diagnostics).to be(:underlying_diagnostics)
      end
    end
  end

  describe '#run' do
    context 'when Oasis results are blank AND we are on page 1 AND no commercial results override is set AND Bing image results are enabled' do
      let(:image_search) { described_class.new(affiliate:, query: 'lsdkjflskjflskjdf') }
      # let(:search_engine_adapter) { double(SearchEngineAdapter, results: nil) }
      let(:odie_image_search) { instance_double(OdieImageSearch, results: nil) }

      before do
        affiliate.is_bing_image_search_enabled = true
        allow(affiliate).to receive(:has_no_social_image_feeds?).and_return false
      end

      # context 'when search_engine is BingV7' do
      #   before { affiliate.search_engine = 'BingV7' }

      #   it 'should perform a Bing image search' do
      #     expect(SearchEngineAdapter).to receive(:new).
      #       with(BingV7ImageSearch,
      #            hash_including(affiliate: affiliate,
      #                           page: 1,
      #                           per_page: 20,
      #                           query: 'lsdkjflskjflskjdf')).
      #       and_return(search_engine_adapter)
      #     expect(search_engine_adapter).to receive(:run)
      #     image_search.run
      #   end
      # end

      context 'when search_engine is SearchGov' do
        before do
          affiliate.search_engine = 'SearchGov'
          allow(OdieImageSearch).to receive(:new).and_return(odie_image_search)
          allow(odie_image_search).to receive(:run)
        end

        it 'performs a ODIE image search' do
          expect(OdieImageSearch).to receive(:new).
            with(hash_including(affiliate:,
                                page: 1,
                                per_page: 20,
                                query: 'lsdkjflskjflskjdf')).
            and_return(odie_image_search)
          image_search.run
        end
      end
    end
  end

  describe '#spelling_suggestion' do
    subject(:image_search) { described_class.new(affiliate:, query: 'lsdkjflskjflskjdf') }

    let(:odie_image_search) { instance_double(OdieImageSearch, default_module_tag: 'module_tag', results: [], spelling_suggestion: 'spel') }

    before do
      affiliate.is_bing_image_search_enabled = true
      allow(SuggestionBlock).to receive(:exists?).and_return(suggestion_block_exists)
      allow(OdieImageSearch).to receive(:new).and_return(odie_image_search)
      allow(odie_image_search).to receive(:run)
    end

    context 'when no suggestion block exists for the given query' do
      let(:suggestion_block_exists) { false }

      it 'returns the search engine spelling suggestion' do
        image_search.run
        expect(image_search.spelling_suggestion).to eq('spel')
      end
    end

    context 'when a suggestion block exists for the given query' do
      let(:suggestion_block_exists) { true }

      it 'returns nil' do
        image_search.run
        expect(image_search.spelling_suggestion).to be_nil
      end
    end
  end
end
