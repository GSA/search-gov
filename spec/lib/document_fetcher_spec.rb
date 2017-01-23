require 'spec_helper'

describe DocumentFetcher do
  describe '.fetch' do
    it 'follows redirects from http to https' do
      response = DocumentFetcher.fetch 'http://healthcare.gov'
      response[:status].should match(/200 OK/)
      response[:last_effective_url].should == 'https://www.healthcare.gov/'
    end

    it 'returns empty hash when Curl::Easy raises error' do
      easy = double('easy')
      Curl::Easy.should_receive(:new).and_return(easy)
      easy.should_receive(:perform).and_raise(Curl::Err::TooManyRedirectsError)
      DocumentFetcher.fetch('http://healthcare.gov').should eq(error: 'Curl::Err::TooManyRedirectsError')
    end

    it 'returns empty hash when the execution expired' do
      easy = double('easy')
      Curl::Easy.should_receive(:new).and_return(easy)
      easy.should_receive(:perform)

      response = DocumentFetcher.fetch('http://healthcare.gov')
      expect(response[:error]).to match(/Unable to fetch/)
    end

    #sanity check, as a lot of tests rely on this working
    it 'can be stubbed by Webmock' do
      stub_request(:get,'https://www.healthcare.gov/').to_return({body: 'foo', status: 200})
      expect(DocumentFetcher.fetch 'https://www.healthcare.gov/').
        to eq ({ body: "foo",  last_effective_url: "https://www.healthcare.gov/", status: "200" })
    end
  end
end
