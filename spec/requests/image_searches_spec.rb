require 'spec_helper'

describe '/search/images' do
  fixtures :affiliates

  context 'when site is not bing image search enabled' do
    let(:affiliate) { affiliates(:usagov_affiliate) }

    before do
      flickr_url = 'https://www.flickr.com/photos/whitehouse'
      profile_id = '35591378@N03'
      flickr_profile = affiliate.flickr_profiles.where(profile_id: profile_id,
                                                       url: flickr_url).first_or_create!
      flickr_id = 100
      5.times do |i|
        flickr_profile.flickr_photos.create!(flickr_id: flickr_id + i,
                                             owner: profile_id,
                                             title: "white house photo #{i}",
                                             url_q: "http://farm9.staticflickr.com/#{i + 1}/#{i + 1}_q.jpg")
      end
      ElasticFlickrPhoto.commit
    end

    context 'when query is present' do
      before do
        get '/search/images.json', { affiliate: affiliate.name, query: 'white house' }
      end

      it 'responds with search results' do
        json_response = JSON.parse(response.body)
        json_response['total'].should == 5
        json_response['startrecord'].should == 1
        json_response['endrecord'].should == 5

        json_response['results'].each do |r|
          r['title'].should start_with('white house photo')
          r['url'].should start_with('http://www.flickr.com/photos/35591378@N03/')
        end
      end
    end

    context 'when query is blank' do
      before do
        get '/search/images.json', { affiliate: affiliate.name, query: ' ' }
      end

      it 'responds with error message' do
        json_response = JSON.parse(response.body)
        json_response['error'].should == 'Please enter search term(s)'
      end
    end
  end

  context 'when site is bing image search enabled' do
    let(:affiliate) { affiliates(:bing_image_search_enabled_affiliate) }
    let(:expected_response_body) { Rails.root.join('spec/fixtures/json/expected_bing_image_search_results.json').read }

    before do
      get '/search/images.json', { affiliate: affiliate.name, query: 'white house' }
    end

    it 'renders JSON response' do
      json_response = JSON.parse(response.body)
      json_response['total'].should == 4340000
      json_response['startrecord'].should == 1
      json_response['endrecord'].should == 10

      expected_json_response = JSON.parse(expected_response_body)
      json_response['results'][0].should == expected_json_response['results'][0]
      json_response['results'][1].should == expected_json_response['results'][1]
      json_response['results'][2].should == expected_json_response['results'][2]
    end
  end
end
