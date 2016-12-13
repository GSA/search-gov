require 'spec_helper'

describe FlickrProfile do
  fixtures :affiliates, :flickr_profiles

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:url) { 'https://www.flickr.com/photos/marine_corps'.freeze }

  it { should belong_to :affiliate }
  it { should validate_presence_of(:affiliate_id) }
  it { should validate_presence_of(:url) }

  context 'when URL is present and valid' do
    before do
      FlickrProfile.any_instance.stub(:lookup_flickr_profile_id).
        with('user', 'https://www.flickr.com/photos/marine_corps').
        and_return('40927340@N03')
    end

    it 'detects profile_type and profile_id' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should be_valid
      fp.profile_type.should == 'user'
      fp.profile_id.should be_present
    end

    context 'when the URL protocol is missing' do
      let(:url) { 'www.flickr.com/photos/marine_corps' }
      let(:fp) { FlickrProfile.new(affiliate: affiliate, url: url) }

      it 'converts the url to https' do
        expect{ fp.valid? }.to change{ fp.url }.
          from('www.flickr.com/photos/marine_corps').
          to('https://www.flickr.com/photos/marine_corps')
      end
    end

    context 'when the URL is http' do
      let(:url) { 'http://www.flickr.com/photos/marine_corps' }
      let(:fp) { FlickrProfile.new(affiliate: affiliate, url: url) }

      it 'converts the url to https' do
        expect{ fp.valid? }.to change{ fp.url }.
          from('http://www.flickr.com/photos/marine_corps').
          to('https://www.flickr.com/photos/marine_corps')
      end
    end

    context 'when profile_id, profile_type and URL are present' do
      it 'skips profile_id and profile_type lookup' do
        fp = FlickrProfile.new affiliate: affiliate, url: url, profile_id: '40927340@N03', profile_type: 'user'
        fp.should be_valid
      end
    end
  end

  context 'when profile_type is not identified' do
    let(:url) { 'https://www.flickr.com/invalid/marine_corps/'.freeze }

    it 'should not lookupUser or lookupGroup' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_not be_valid
      fp.profile_type.should be_blank
    end
  end

  context 'when Flickr lookupUser fails' do
    it 'should not be valid' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_receive(:lookup_flickr_profile_id).with('user', url).and_return(nil)
      fp.should_not be_valid
    end
  end

  context 'when Flickr lookupGroup fails' do
    let(:url) { 'https://www.flickr.com/groups/usagov/'.freeze }

    it 'should not be valid' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.should_receive(:lookup_flickr_profile_id).with('group', url).and_return(nil)
      fp.should_not be_valid
    end
  end

  context 'when adding a profile that already exists for the given affiliate' do
    before do
      FlickrData.stub(:lookup_flickr_profile_id).
        with('user', url).
        and_return('40927340@N03')
    end

    it 'should not be valid' do
      first = FlickrProfile.new affiliate: affiliate, url: url
      first.stub(:lookup_flickr_profile_id).with('user', url).and_return('40927340@N03')
      first.save!
      fp = FlickrProfile.new affiliate: affiliate, url: url
      fp.stub(:lookup_flickr_profile_id).with('user', url).and_return('40927340@N03')
      fp.should_not be_valid
    end
  end

  it 'should notify Oasis after create' do
    Oasis.should_receive(:subscribe_to_flickr).with('40927340@N03', 'marine_corps', 'user')
    fp = FlickrProfile.new(url: url, affiliate: affiliate)
    fp.stub(:lookup_flickr_profile_id).with('user', url).and_return('40927340@N03')
    fp.save!
  end

  describe '#dup' do
    let(:original_instance) { flickr_profiles(:group) }

    include_examples 'site dupable'

    its(:skip_notify_oasis) { should be true }
  end
end
