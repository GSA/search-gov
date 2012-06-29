require 'spec/spec_helper'

describe FlickrProfileImporter, "#perform(flickr_profile_id)" do
  fixtures :affiliates
  before do
    @aff = affiliates(:power_affiliate)
    FlickrProfile.destroy_all
    @flickr_profile = @aff.flickr_profiles.create(:url => 'http://flickr.com/photos/usagov')
  end

  context "when it can't locate the FlickrProfile for a given id" do
    it "should ignore the entry" do
      @flickr_profile.should_not_receive(:import_photos)
      FlickrProfileImporter.perform(-1)
    end
  end

  context "when it can locate the Superfresh URL entry for a given url & affiliate_id" do
    before do
      FlickrProfile.stub!(:find_by_id).and_return @flickr_profile
    end

    it "should attempt to fetch and index the document" do
      @flickr_profile.should_receive(:import_photos)
      FlickrProfileImporter.perform(@flickr_profile.id)
    end
  end
end