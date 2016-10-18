require 'spec_helper'

describe DocumentFetcher do
  describe '.fetch' do
    it 'follows redirects from http to https' do
      response = DocumentFetcher.fetch 'http://healthcare.gov'
      response[:status].should match(/301/)
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
  end
end
