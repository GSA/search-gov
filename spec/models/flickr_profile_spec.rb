require 'spec_helper'

describe FlickrProfile do
  fixtures :affiliates, :flickr_profiles

  let(:affiliate) { affiliates(:basic_affiliate) }

  it { should belong_to :affiliate }
  it { should validate_presence_of(:affiliate_id) }
  it { should validate_presence_of(:url) }

  context 'when URL is present and valid' do
    let(:flickr_response) { { 'id' => '40927340@N03', 'username' => 'United States Marine Corps Official Page' } }
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    before { flickr.urls.should_receive(:lookupUser).with(url: url).and_return(flickr_response) }

    it 'detects profile_type and profile_id' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should be_valid
      fp.profile_type.should == 'user'
      fp.profile_id.should be_present
    end
  end

  context 'when profile_type is not identified' do
    let(:url) { 'https://www.flickr.com/invalid/marine_corps/'.freeze }

    it 'should not lookupUser or lookupGroup' do
      flickr.should_not_receive(:urls)

      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
      fp.profile_type.should be_blank
    end
  end

  context 'when Flickr lookupUser fails' do
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    it 'should not be valid' do
      flickr.urls.should_receive(:lookupUser).
          with(url: url).
          and_raise(FlickRaw::FailedResponse.new('User not found', 1, 'flickr.urls.lookupUser') )
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  context 'when Flickr lookupGroup fails' do
    let(:url) { 'https://www.flickr.com/groups/usagov/'.freeze }

    it 'should not be valid' do
      flickr.urls.should_receive(:lookupGroup).
          with(url: url).
          and_raise(FlickRaw::FailedResponse.new('Group not found', 1, 'flickr.urls.lookupGroup') )
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  context 'when adding a profile that already exists for the given affiliate' do
    let(:flickr_response) { { 'id' => '40927340@N03', 'username' => 'United States Marine Corps Official Page' } }
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    before { flickr.urls.stub(:lookupUser).and_return(flickr_response) }

    it 'should not be valid' do
      FlickrProfile.create! affiliate: affiliate, url: url
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  it 'should notify Oasis after create' do
    flickr_response = { 'id' => '40927340@N03', 'username' => 'United States Marine Corps Official Page' }
    url = 'https://www.flickr.com/photos/marine_corps/'.freeze
    flickr.urls.should_receive(:lookupUser).with(url: url).and_return(flickr_response)
    Oasis.should_receive(:subscribe_to_flickr).with('40927340@N03', 'marine_corps', 'user')
    FlickrProfile.create(url: url, affiliate: affiliate)
  end

end
