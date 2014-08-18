require 'spec_helper'

describe SearchEngineAdapter do
  fixtures :affiliates

  describe "#default_spelling_module_tag" do
    context "when adapter is a BingImageSearch" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:search_engine_adapter) { SearchEngineAdapter.new(BingImageSearch, { affiliate: affiliate, query: "test", page: 1, per_page: 10 }) }

      it "should return BSPEL" do
        search_engine_adapter.default_spelling_module_tag.should == "BSPEL"
      end
    end
  end
end