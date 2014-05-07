require 'spec_helper'

describe DocumentFetcher do
  describe '.fetch' do
    it 'follows redirects from http to https' do
      response = DocumentFetcher.fetch 'http://healthcare.gov'
      response[:status].should match(/301/)
      response[:last_effective_url].should == 'https://www.healthcare.gov/'
    end

    it 'returns empty hash when Curl::Easy raises error' do
      easy = mock('easy')
      Curl::Easy.should_receive(:new).and_return(easy)
      easy.should_receive(:perform).and_raise(Curl::Err::TooManyRedirectsError)
      DocumentFetcher.fetch('http://healthcare.gov').should == {}
    end

    it 'returns empty hash when the execution expired' do
      Timeout.should_receive(:timeout).with(10).and_raise Timeout::Error
      Rails.logger.should_receive(:warn).with(/execution expired/)
      DocumentFetcher.fetch('http://healthcare.gov').should == {}
    end
  end
end
