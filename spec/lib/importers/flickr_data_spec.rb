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

      before { flickr.urls.stub(:lookupUser).and_return(flickr_response) }

      it 'returns a valid instance' do
        url = 'https://www.flickr.com/photos/marine_corps/'.freeze
        flickr_data = FlickrData.new(site, url)
        profile = flickr_data.import_profile
        profile.should_not be_new_record
        profile.profile_id.should eq('40927340@N03')
        profile.profile_type.should eq('user')
      end

    end

    context 'when url does not refer to a valid flickr profile' do
      before do
        flickr.urls.stub(:lookupUser).and_raise
      end

      it 'returns nil' do
        url = 'https://www.flickr.com/photos/dg_search/'.freeze
        flickr_data = FlickrData.new(site, url)
        profile = flickr_data.import_profile
        profile.should be_nil
      end
    end
  end

  describe "#new_profile_created?" do
    before { flickr.urls.stub(:lookupUser).and_return(flickr_response) }
    it 'returns whether or not a new FlickrProfile got created' do
      url = 'https://www.flickr.com/photos/marine_corps/'.freeze
      flickr_data = FlickrData.new(site, url)
      flickr_data.import_profile
      flickr_data.new_profile_created.should be true
      rerun_flickr_data = FlickrData.new(site, url)
      rerun_flickr_data.import_profile
      rerun_flickr_data.new_profile_created.should be false
    end
  end
end
