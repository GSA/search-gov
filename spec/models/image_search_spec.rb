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
      let(:odie_image_search) { instance_double(OdieImageSearch, results: nil) }

      context 'when search_engine is SearchGov' do
        before do
          affiliate.search_engine = 'SearchGov'
          allow(OdieImageSearch).to receive(:new).and_return(odie_image_search)
          allow(odie_image_search).to receive(:run)
        end

        it 'performs a ODIE image search' do
          image_search.run
          expect(OdieImageSearch).to have_received(:new).
            with(hash_including(affiliate:,
                                page: 1,
                                per_page: 20,
                                query: 'lsdkjflskjflskjdf'))
        end
      end
    end
  end

  describe '#format_results' do
    subject(:image_search) { described_class.new(affiliate:, query: 'some query') }

    let(:total) { 10 }
    let(:search_instance) { instance_double(OdieImageSearch, results:, total:) }
    let(:post_processor) { instance_double(ImageResultsPostProcessor, normalized_results: nil) }
    let(:results) { 'true' }

    before do
      image_search.instance_variable_set(:@search_instance, search_instance)
      allow(ImageResultsPostProcessor).to receive(:new).and_return(post_processor)
      allow(post_processor).to receive(:normalized_results)
    end

    it 'formats results using ImageResultsPostProcessor' do
      image_search.format_results
      expect(ImageResultsPostProcessor).to have_received(:new).with(total, results)
    end
  end

  describe '#commercial_results?' do
    subject(:image_search) { described_class.new(affiliate:, query: 'some query') }

    context 'when module_tag includes IMAG' do
      before { image_search.instance_variable_set(:@module_tag, 'IMAG') }

      it 'returns true' do
        expect(image_search.commercial_results?).to be true
      end
    end

    context 'when module_tag does not include IMAG' do
      before { image_search.instance_variable_set(:@module_tag, 'OtherTag') }

      it 'returns false' do
        expect(image_search.commercial_results?).to be false
      end
    end
  end

  describe '#engine_klass' do
    subject(:image_search) { described_class.new(affiliate:, query: 'some query') }

    context 'when affiliate search engine starts with Bing' do
      before { affiliate.search_engine = 'BingV7' }

      it 'returns the appropriate search engine class' do
        expect(image_search.send(:engine_klass)).to eq(BingV7ImageSearch)
      end
    end

    context 'when affiliate search engine does not start with Bing' do
      before { affiliate.search_engine = 'SearchGov' }

      it 'returns the latest BingV7ImageSearch class' do
        expect(image_search.send(:engine_klass)).to eq(BingV7ImageSearch)
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
