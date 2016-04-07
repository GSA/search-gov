require 'spec_helper'

describe '/search/images' do
  fixtures :affiliates, :instagram_profiles

  context 'when site is not bing image search enabled' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:search_engine_response) do
      SearchEngineResponse.new do |search_response|
        search_response.total = 2
        search_response.start_record = 1
        search_response.results = [Hashie::Rash.new(title: 'white house photo 1', url: "http://www.flickr.com/photos/35591378@N03/2", thumbnail_url: "http://thumbnailurl1"), Hashie::Rash.new(title: 'white house photo 2', url: "http://www.flickr.com/photos/35591378@N03/2", thumbnail_url: "http://thumbnailurl2")]
        search_response.end_record = 2
      end
    end

    before do
      affiliate.instagram_profiles << instagram_profiles(:whitehouse)
      oasis_search = mock(OasisSearch)
      OasisSearch.stub(:new).and_return oasis_search
      oasis_search.stub(:execute_query).and_return search_engine_response
    end

    context 'when query is present' do
      before do
        get '/search/images.json', { affiliate: affiliate.name, query: 'white house' }
      end

      it 'responds with search results from Oasis' do
        json_response = JSON.parse(response.body)
        json_response['total'].should == 2
        json_response['startrecord'].should == 1
        json_response['endrecord'].should == 2

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
        json_response['error'].should == 'Please enter a search term in the box above.'
      end
    end
  end

  context 'when site is bing image search enabled' do
    let(:affiliate) { affiliates(:bing_image_search_enabled_affiliate) }

    before do
      get '/search/images.json', { affiliate: affiliate.name, query: 'white house' }
    end

    it 'renders JSON response' do
      json_response = JSON.parse(response.body)
      json_response['total'].should == 4340000
      json_response['startrecord'].should == 1
      json_response['endrecord'].should == 10

      json_response['results'][0].should == {
        "title" => "White House, Washington D.C.",
        "media_url" => "http://biglizards.net/Graphics/ForegroundPix/White_House.JPG",
        "url" => "http://biglizards.net/blog/archives/2008/08/",
        "display_url" => "http://biglizards.net/blog/archives/2008/08/",
        "width" => 391,
        "height" => 428,
        "file_size" => 37731,
        "content_type" => "image/jpeg",
        "thumbnail" => {"url"=>"http://ts1.mm.bing.net/images/thumbnail.aspx?q=1581721453740&id=869b85a01b58c5a200496285e0144df1", "content_type"=>"image/jpeg", "width"=>146, "height"=>160, "file_size"=>4719}
      }
      json_response['results'][1].should == {
        "title"=>"The White House",
        "media_url"=>"http://www.fas.org/nuke/guide/usa/c3i/ikonos_white_house_full_010.jpg",
        "url"=>"http://www.fas.org/nuke/guide/usa/c3i/peoc.htm",
        "display_url"=>"http://www.fas.org/nuke/guide/usa/c3i/peoc.htm",
        "width"=>800,
        "height"=>730,
        "file_size"=>169355,
        "content_type"=>"image/jpeg",
        "thumbnail"=>{"url"=>"http://ts2.mm.bing.net/images/thumbnail.aspx?q=1438163676057&id=ee6f2aba0b757948bf82808fe23efcfd", "content_type"=>"image/jpeg", "width"=>160, "height"=>146, "file_size"=>6991}
      }
      json_response['results'][2].should == {
        "title"=>"White House in Winter",
        "media_url"=>"http://www.enidromanek.com/Graphics/White_House_in_Winter.jpg",
        "url"=>"http://www.enidromanek.com/White_House_in_Winter.htm",
        "display_url"=>"http://www.enidromanek.com/White_House_in_Winter.htm",
        "width"=>350,
        "height"=>240,
        "file_size"=>16631,
        "content_type"=>"image/jpeg",
        "thumbnail"=>{"url"=>"http://ts2.mm.bing.net/images/thumbnail.aspx?q=1357037516421&id=1a2730ccb42b11876e9593eeae3db7a2", "content_type"=>"image/jpeg", "width"=>160, "height"=>109, "file_size"=>4235}
      }
    end
  end
end
