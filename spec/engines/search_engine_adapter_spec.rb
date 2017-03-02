require 'spec_helper'

describe SearchEngineAdapter do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe "#results" do
    context 'when query is blank' do
      let(:search_engine_adapter) { SearchEngineAdapter.new(BingV6ImageSearch, { affiliate: affiliate, query: "", page: 1, per_page: 10 }) }

      it 'should return nil' do
        search_engine_adapter.results.should be_nil
      end
    end
  end

  describe "#run" do
    context 'when Bing errors out' do
      let(:search_engine_adapter) { SearchEngineAdapter.new(BingV6ImageSearch, { affiliate: affiliate, query: "test", page: 1, per_page: 10 }) }
      before do
        ActiveSupport::Notifications.stub(:instrument).and_raise SearchEngine::SearchError
      end

      it 'should return false' do
        search_engine_adapter.run.should be false
      end
    end
  end

  describe "#default_spelling_module_tag" do
    subject { SearchEngineAdapter.new(BingV6ImageSearch, { affiliate: affiliate, query: "", page: 1, per_page: 10 }) }

    it 'should be BSPEL' do
      expect(subject.default_spelling_module_tag).to eq('BSPEL')
    end
  end
end
