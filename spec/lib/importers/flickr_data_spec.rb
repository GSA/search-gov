require 'spec_helper'

describe FlickrData do
  fixtures :affiliates

  describe '.import_profile' do
    let(:site) { affiliates(:basic_affiliate) }

    context 'when url refers to a valid flickr profile' do
      let(:flickr_response) do
        { 'id' => '40927340@N03',
          'username' => 'United States Marine Corps Official Page' }
      end

      before { flickr.urls.stub(:lookupUser).and_return(flickr_response) }

      it 'returns a valid instance' do
        url = 'https://www.flickr.com/photos/marine_corps/'.freeze

        profile = FlickrData.import_profile site, url
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
        profile = FlickrData.import_profile site, url
        profile.should be_nil
      end
    end
  end
end
