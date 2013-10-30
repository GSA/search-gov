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
    context "when CloudFiles raise NoSuchContainer" do
      let(:affiliate) { mock_model(Affiliate, :css_property_hash => {}, :page_background_image_file_name => 'bg.png')}
      it "should return only background-color" do
        helper.should_receive(:render_affiliate_css_property_value).with({}, :page_background_color).and_return('#DDDDDD')
        affiliate.should_receive(:page_background_image).and_raise(CloudFiles::Exception::NoSuchContainer)
        helper.render_affiliate_body_style(affiliate).should == 'background-color: #DDDDDD'
      end
    end
  end
end
