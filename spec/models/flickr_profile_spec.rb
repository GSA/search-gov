require 'spec_helper'

describe FlickrProfile do
  fixtures :affiliates, :flickr_profiles

  let(:affiliate) { affiliates(:basic_affiliate) }

  it { should belong_to :affiliate }
  it { should validate_presence_of(:affiliate_id) }
  it { should validate_presence_of(:url) }

  context 'when URL is present and valid' do
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    before do
      FlickrData.should_receive(:lookup_profile_id).
        with('user', url).
        and_return('40927340@N03')
    end

    it 'detects profile_type and profile_id' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should be_valid
      fp.profile_type.should == 'user'
      fp.profile_id.should be_present
    end
  end

  context 'when profile_id, profile_type and URL are present' do
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    before do
      FlickrData.should_not_receive(:detect_profile_type)
      FlickrData.should_not_receive(:lookup_profile_id)
    end

    it 'skips profile_id and profile_type lookup' do
      fp = FlickrProfile.new affiliate: affiliate, url: url, profile_id: '40927340@N03', profile_type: 'user'
      fp.should be_valid
    end
  end

  context 'when profile_type is not identified' do
    let(:url) { 'https://www.flickr.com/invalid/marine_corps/'.freeze }

    it 'should not lookupUser or lookupGroup' do
      FlickrData.should_not_receive(:lookup_profile_id)

      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
      fp.profile_type.should be_blank
    end
  end

  context 'when Flickr lookupUser fails' do
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    it 'should not be valid' do
      FlickrData.should_receive(:lookup_profile_id).
        with('user', url).
        and_return(nil)
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  context 'when Flickr lookupGroup fails' do
    let(:url) { 'https://www.flickr.com/groups/usagov/'.freeze }

    it 'should not be valid' do
      FlickrData.should_receive(:lookup_profile_id).
        with('group', url).
        and_return(nil)
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  context 'when adding a profile that already exists for the given affiliate' do
    let(:url) { 'https://www.flickr.com/photos/marine_corps/'.freeze }

    before do
      FlickrData.stub(:lookup_profile_id).
        with('user', url).
        and_return('40927340@N03')
    end

    it 'should not be valid' do
      FlickrProfile.create! affiliate: affiliate, url: url
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
    end
  end

  it 'should notify Oasis after create' do
    url = 'https://www.flickr.com/photos/marine_corps/'.freeze
    FlickrData.stub(:lookup_profile_id).
      with('user', url).
      and_return('40927340@N03')

    Oasis.should_receive(:subscribe_to_flickr).with('40927340@N03', 'marine_corps', 'user')
    FlickrProfile.create(url: url, affiliate: affiliate)
  end

end
