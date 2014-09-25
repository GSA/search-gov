require 'spec_helper'

describe SearchEngineAdapter do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe "#default_spelling_module_tag" do
    context "when adapter is a BingImageSearch" do
      let(:search_engine_adapter) { SearchEngineAdapter.new(BingImageSearch, { affiliate: affiliate, query: "test", page: 1, per_page: 10 }) }

      it "should return BSPEL" do
        search_engine_adapter.default_spelling_module_tag.should == "BSPEL"
      end
    end
  end

  describe "#results" do
    context 'when query is blank' do
      let(:search_engine_adapter) { SearchEngineAdapter.new(BingImageSearch, { affiliate: affiliate, query: "", page: 1, per_page: 10 }) }

      it 'should return nil' do
        search_engine_adapter.results.should be_nil
      end
    end
  end

  describe "#run" do
    context 'when Bing errors out' do
      let(:search_engine_adapter) { SearchEngineAdapter.new(BingImageSearch, { affiliate: affiliate, query: "test", page: 1, per_page: 10 }) }
      before do
        ActiveSupport::Notifications.stub(:instrument).and_raise SearchEngine::SearchError
      end

      it 'should return false' do
        search_engine_adapter.run.should be_false
      end
    end
  end
end