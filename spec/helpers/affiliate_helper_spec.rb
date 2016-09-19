require 'spec_helper'

describe AffiliateHelper do
  describe "#render_managed_header" do
    context "when the affiliate has a header image and an exception occurs when trying to retrieve the image" do
      let(:header_image) { mock('header image') }
      let(:affiliate) { mock_model(Affiliate,
                                   :css_property_hash => Affiliate::DEFAULT_CSS_PROPERTIES,
                                   :header_image_file_name => 'logo.gif',
                                   :header_image => header_image) }

      before do
        header_image.should_receive(:url).and_raise
      end

      specify { helper.render_managed_header(affiliate).should_not have_select(:img) }
    end
  end

  describe "#render_affiliate_body_style" do
    context "when an error occurs" do
      let(:affiliate) { mock_model(Affiliate, :css_property_hash => {}, :page_background_image_file_name => 'bg.png')}
      it "should return only background-color" do
        helper.should_receive(:render_affiliate_css_property_value).with({}, :page_background_color).and_return('#DDDDDD')
        affiliate.should_receive(:page_background_image).and_raise(StandardError)
        helper.render_affiliate_body_style(affiliate).should == 'background-color: #DDDDDD'
      end
    end

    context "when the affiliate has a background image configured" do
      let(:affiliate) do
        mock_model(Affiliate, {
          page_background_image_file_name: 'background.png',
          page_background_image: mock('background_image', url: 'some_background_url'),
          css_property_hash: { page_background_image_repeat: 'some_background_repeat' },
        })
      end

      it "includes the background image as background image style" do
        expected_style = 'background: #DFDFDF url(some_background_url) some_background_repeat center top'
        helper.render_affiliate_body_style(affiliate).should eq(expected_style)
      end
    end
  end
end
