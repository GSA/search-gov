require 'spec_helper'

describe SearchEngineAdapter do
  fixtures :affiliates
  subject(:search_engine_adapter) { SearchEngineAdapter.new(BingV6ImageSearch, { affiliate: affiliate, query: query, page: 1, per_page: 10 }) }
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:query) { 'test' }

  describe '#results' do
    context 'when query is blank' do
      let(:query) { '' }

      it 'should return nil' do
        expect(search_engine_adapter.results).to be_nil
      end
    end

    context 'when underlying search errors out' do
      before do
        allow(ActiveSupport::Notifications).to receive(:instrument).and_raise SearchEngine::SearchError
        search_engine_adapter.run
      end

      it 'should not raise an error' do
        expect { search_engine_adapter.results }.to_not raise_error
      end
    end
  end

  describe '#run' do
    context 'when Bing errors out' do
      before do
        allow(ActiveSupport::Notifications).to receive(:instrument).and_raise SearchEngine::SearchError
      end

      it 'should return false' do
        expect(search_engine_adapter.run).to be false
      end
    end
  end

  describe '#default_spelling_module_tag' do
    subject { SearchEngineAdapter.new(BingV6ImageSearch, { affiliate: affiliate, query: '', page: 1, per_page: 10 }) }

    it 'should be BSPEL' do
      expect(subject.default_spelling_module_tag).to eq('BSPEL')
    end
  end
end
