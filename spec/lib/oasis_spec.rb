require 'spec_helper'

describe Oasis do
  describe ".subscribe_to_instagram(id, username)" do
    it 'should POST subscription details to Oasis Instagram endpoint' do
      Net::HTTP.should_receive(:post_form).with(URI.parse(Oasis::INSTAGRAM_API_ENDPOINT), { id: "1234", username: "foobar" })
      Oasis.subscribe_to_instagram("1234", "foobar")
    end

    context "when an exception is raised during the POST" do
      before do
        Net::HTTP.stub(:post_form).and_raise
      end

      it "should capture and log it" do
        Rails.logger.should_receive(:warn)
        Oasis.subscribe_to_instagram("1234", "foobar")
      end
    end
  end

  describe ".subscribe_to_flickr(id, name, profile_type)" do
    it 'should POST subscription details to Oasis Flickr endpoint' do
      Net::HTTP.should_receive(:post_form).with(URI.parse(Oasis::FLICKR_API_ENDPOINT), { id: "1234", name: "foobar", profile_type: "user" })
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
end
