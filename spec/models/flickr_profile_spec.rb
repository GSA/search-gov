require 'spec_helper'

describe FlickrProfile do
  fixtures :affiliates, :flickr_profiles

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:url) { 'https://www.flickr.com/photos/marine_corps'.freeze }

  it { is_expected.to belong_to :affiliate }
  it { is_expected.to validate_presence_of(:affiliate_id) }
  it { is_expected.to validate_presence_of(:url) }

  context 'when URL is present and valid' do
    before do
      allow_any_instance_of(FlickrProfile).to receive(:lookup_flickr_profile_id).
        with('user', 'https://www.flickr.com/photos/marine_corps').
        and_return('40927340@N03')
    end

    it 'detects profile_type and profile_id' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      expect(fp).to be_valid
      expect(fp.profile_type).to eq('user')
      expect(fp.profile_id).to be_present
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
        expect(fp).to be_valid
      end
    end
  end

  context 'when profile_type is not identified' do
    let(:url) { 'https://www.flickr.com/invalid/marine_corps/'.freeze }

    it 'should not lookupUser or lookupGroup' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      expect(fp).not_to be_valid
      expect(fp.profile_type).to be_blank
    end
  end

  context 'when Flickr lookupUser fails' do
    it 'should not be valid' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      expect(fp).to receive(:lookup_flickr_profile_id).with('user', url).and_return(nil)
      expect(fp).not_to be_valid
    end
  end

  context 'when Flickr lookupGroup fails' do
    let(:url) { 'https://www.flickr.com/groups/usagov/'.freeze }

    it 'should not be valid' do
      fp = FlickrProfile.new affiliate: affiliate, url: url
      expect(fp).to receive(:lookup_flickr_profile_id).with('group', url).and_return(nil)
      expect(fp).not_to be_valid
    end
  end

  context 'when adding a profile that already exists for the given affiliate' do
    before do
      allow(FlickrData).to receive(:lookup_flickr_profile_id).
        with('user', url).
        and_return('40927340@N03')
    end

    it 'should not be valid' do
      first = FlickrProfile.new affiliate: affiliate, url: url
      allow(first).to receive(:lookup_flickr_profile_id).with('user', url).and_return('40927340@N03')
      first.save!
      fp = FlickrProfile.new affiliate: affiliate, url: url
      allow(fp).to receive(:lookup_flickr_profile_id).with('user', url).and_return('40927340@N03')
      expect(fp).not_to be_valid
    end
  end

  it 'should notify Oasis after create' do
    expect(Oasis).to receive(:subscribe_to_flickr).with('40927340@N03', 'marine_corps', 'user')
    fp = FlickrProfile.new(url: url, affiliate: affiliate)
    allow(fp).to receive(:lookup_flickr_profile_id).with('user', url).and_return('40927340@N03')
    fp.save!
  end

  describe '#dup' do
    let(:original_instance) { flickr_profiles(:group) }

    include_examples 'site dupable'

    its(:skip_notify_oasis) { should be true }
  end
end
