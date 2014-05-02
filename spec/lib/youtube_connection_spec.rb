require 'spec_helper'

describe YoutubeConnection do
  describe '.get' do
    context 'when status code is 200' do
      it 'returns the response body' do
        body = 'response body'.freeze
        response = mock('response', status: 200, body: body)
        $youtube_connection.should_receive(:get).and_return(response)

        YoutubeConnection.get('url').should == body
      end
    end

    context 'when response body contains yt:quota' do
      it 'raises QuotaError' do
        error_body = '<errors><error><domain>yt:quota</domain><code>too_many_recent_calls</code></error></errors>'
        response = mock('response', status: 403, body: error_body)
        $youtube_connection.should_receive(:get).and_return(response)
        lambda { YoutubeConnection.get('url') }.should raise_error(YoutubeConnection::QuotaError)
      end
    end

    context 'when status code is 400 and response body does not contain yt:quota' do
      it 'raises RequestError' do
        error_body = 'You cannot request beyond item 500.'
        response = mock('response', status: 400, body: error_body)
        $youtube_connection.should_receive(:get).and_return(response)
        lambda { YoutubeConnection.get('url') }.should raise_error(YoutubeConnection::RequestError)
      end
    end
  end
end
