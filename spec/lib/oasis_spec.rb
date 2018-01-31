require 'spec_helper'

describe Oasis do
  describe ".subscribe_to_flickr(id, name, profile_type)" do
    it 'should POST subscription details to Oasis Flickr endpoint' do
      Net::HTTP.should_receive(:post_form).with(URI.parse("http://localhost:8080#{Oasis::FLICKR_API_ENDPOINT}"), { id: "1234", name: "foobar", profile_type: "user" })
      Oasis.subscribe_to_flickr("1234", "foobar", "user")
    end

    context "when an exception is raised during the POST" do
      before do
        Net::HTTP.stub(:post_form).and_raise
      end

      it "should capture and log it" do
        Rails.logger.should_receive(:warn)
        Oasis.subscribe_to_flickr("1234", "foobar", "user")
      end
    end
  end

  describe ".subscribe_to_mrss(url)" do
    it 'should POST subscription details to Oasis Mrss endpoint' do
      Net::HTTP.should_receive(:post_form).with(URI.parse("http://localhost:8080#{Oasis::MRSS_API_ENDPOINT}"), { url: "http://landsat.usgs.gov/LandsatImageGallery.php" })
      Oasis.subscribe_to_mrss("http://landsat.usgs.gov/LandsatImageGallery.php")
    end

    context "when an exception is raised during the POST" do
      before do
        Net::HTTP.stub(:post_form).and_raise
      end

      it "should capture and log it" do
        Rails.logger.should_receive(:warn)
        Oasis.subscribe_to_mrss("http://landsat.usgs.gov/LandsatImageGallery.php")
      end
    end
  end
end
