require 'spec_helper'

describe YoutubeVideosParser do
  class TestYoutubeVideosParser
    extend YoutubeVideosParser
  end
  describe '#feed_document' do
    it 'should sleep and retry 3 times before raising the error' do
      YoutubeConnection.should_receive(:get).exactly(4).times.
          and_raise YoutubeConnection::ConnectionError
      TestYoutubeVideosParser.should_receive(:sleep).exactly(3).times.with(18.minutes)
      lambda { TestYoutubeVideosParser.feed_document('url') }.
          should raise_error(YoutubeConnection::ConnectionError)
    end
  end
end
