require 'spec_helper'

describe YoutubeDocumentFetcher do
  class TestYoutubeDocumentFetcher
    extend YoutubeDocumentFetcher
  end
  describe '#feed_document' do
    context 'when YoutubeConnection raises YoutubeConnection::QuotaError' do
      it 'should sleep and retry 3 times before raising the error' do
        YoutubeConnection.should_receive(:get).exactly(4).times.
            and_raise YoutubeConnection::QuotaError
        TestYoutubeDocumentFetcher.should_receive(:sleep).exactly(3).times.with(18.minutes)
        lambda { TestYoutubeDocumentFetcher.fetch_document('url') }.
            should raise_error(YoutubeConnection::QuotaError)
      end
    end

    context 'when YoutubeConnection raise YoutubeConnection::RequestError' do
      it 'raises the error without retry' do
        YoutubeConnection.should_receive(:get).and_raise(YoutubeConnection::RequestError)
        lambda { TestYoutubeDocumentFetcher.fetch_document('url') }.
            should raise_error(YoutubeConnection::RequestError)
      end
    end
  end
end
