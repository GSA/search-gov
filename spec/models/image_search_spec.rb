require 'spec_helper'

describe ImageSearch do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe ".new" do
    context 'when affiliate has no social media for images' do
      before do
        affiliate.stub(:has_no_social_image_feeds?).and_return true
      end

      it 'should use commercial results instead of Oasis' do
        image_search = ImageSearch.new(affiliate: affiliate, query: "some query")
        image_search.uses_cr.should be_true
      end
    end
  end

  describe "#run" do
    context 'when Oasis results are blank AND we are on page 1 AND no commercial results override is set AND Bing image results are enabled' do
      let(:image_search) { ImageSearch.new(affiliate: affiliate, query: "lsdkjflskjflskjdf") }

      before do
        affiliate.update_attribute(:is_bing_image_search_enabled, true)
        affiliate.stub(:has_no_social_image_feeds?).and_return false
      end

      it 'should perform a Bing image search' do
        search_engine_adapter = mock(SearchEngineAdapter, results: nil)
        SearchEngineAdapter.should_receive(:new).and_return search_engine_adapter
        search_engine_adapter.should_receive(:run)
        image_search.run
      end
    end

  end
end