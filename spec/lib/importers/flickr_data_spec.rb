require 'spec_helper'

describe FlickrData do
  fixtures :affiliates
  let(:site) { affiliates(:basic_affiliate) }

  let(:flickr_response) do
    { 'id' => '40927340@N03',
      'username' => 'United States Marine Corps Official Page' }
  end

  describe '#import_profile' do

    context 'when url refers to a valid flickr profile' do

      before { allow(flickr.urls).to receive(:lookupUser).and_return(flickr_response) }

      it 'returns a valid instance' do
        url = 'https://www.flickr.com/photos/marine_corps/'.freeze
        flickr_data = FlickrData.new(site, url)
        profile = flickr_data.import_profile
        expect(profile).not_to be_new_record
        expect(profile.profile_id).to eq('40927340@N03')
        expect(profile.profile_type).to eq('user')
      end

    end

    context 'when url does not refer to a valid flickr profile' do
      before do
        allow(flickr.urls).to receive(:lookupUser).and_raise
      end

      it 'returns nil' do
        url = 'https://www.flickr.com/photos/dg_search/'.freeze
        flickr_data = FlickrData.new(site, url)
        profile = flickr_data.import_profile
        expect(profile).to be_nil
      end
    end
  end

  describe "#new_profile_created?" do
    before { allow(flickr.urls).to receive(:lookupUser).and_return(flickr_response) }
    it 'returns whether or not a new FlickrProfile got created' do
      url = 'https://www.flickr.com/photos/marine_corps/'.freeze
      flickr_data = FlickrData.new(site, url)
      flickr_data.import_profile
      expect(flickr_data.new_profile_created).to be true
      rerun_flickr_data = FlickrData.new(site, url)
      rerun_flickr_data.import_profile
      expect(rerun_flickr_data.new_profile_created).to be false
    end
  end
end
