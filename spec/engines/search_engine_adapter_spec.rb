require 'spec_helper'

describe SearchEngineAdapter do
  fixtures :affiliates
  subject(:search_engine_adapter) { described_class.new(OdieImageSearch, { affiliate:, query:, page: 1, per_page: 10 }) }

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:query) { 'test' }

  describe '#results' do
    context 'when query is blank' do
      let(:query) { '' }

      it 'returns nil' do
        expect(search_engine_adapter.results).to be_nil
      end
    end

    context 'when underlying search errors out' do
      before do
        allow(ActiveSupport::Notifications).to receive(:instrument).and_raise SearchEngine::SearchError
        search_engine_adapter.run
      end

      it 'does not raise an error' do
        expect { search_engine_adapter.results }.not_to raise_error
      end
    end
  end

  context 'when there are search results' do
    let(:thumbnail) { 'thumbnail' }
    let(:result) { 'result' }
    let(:search_res) { 'SearchResponse' }
    let(:result_double) { instance_double(result, thumbnail:) }
    let(:results) { [result_double, instance_double(result, thumbnail: nil)] }
    let(:search_response) { instance_double(search_res, results:, total: 100) }
    let(:collection) { instance_double(WillPaginate::Collection) }

    before do
      search_engine_adapter.stub(:search).and_return(search_response)
      allow(WillPaginate::Collection).to receive(:new).and_return(collection)
      allow(WillPaginate::Collection).to receive(:create).and_call_original
      allow(collection).to receive(:replace).with([results.first])
      search_engine_adapter.run
    end

    it 'paginates the results' do
      expect(search_engine_adapter.results).not_to be_nil
      expect(WillPaginate::Collection).to have_received(:create).with(1, 10, 100)
      expect(collection).to have_received(:replace).with([results.first])
    end

    it 'selects results with thumbnails present' do
      expect(search_engine_adapter.send(:post_process_results, results)).to eq([results.first])
    end
  end

  describe '#run' do
    context 'when Bing errors out' do
      before do
        allow(ActiveSupport::Notifications).to receive(:instrument).and_raise SearchEngine::SearchError
      end

      it 'returns false' do
        expect(search_engine_adapter.run).to be false
      end
    end
  end

  describe '#default_spelling_module_tag' do
    subject(:search_engine_adapter_module_tag) { described_class.new(OdieImageSearch, { affiliate:, query: '', page: 1, per_page: 10 }) }

    it 'is BSPEL' do
      expect(search_engine_adapter_module_tag.default_spelling_module_tag).to eq('BSPEL')
    end
  end
end
