require 'spec_helper'

describe ImageSearch do
  fixtures :affiliates

  describe ".new" do
    context 'when affiliate has no social media for images' do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        affiliate.stub(:has_no_social_image_feeds?).and_return true
      end

      it 'should use commercial results instead of Oasis' do
        image_search = ImageSearch.new(affiliate: affiliate, query: "some query")
        image_search.uses_cr.should be_true
      end
    end
  end
end