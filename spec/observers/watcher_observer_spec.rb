require 'spec_helper'

describe WatcherObserver do
  let(:watcher) { mock_model(Watcher, id: 123, body: 'body') }
  let(:observer) { described_class.instance }

  describe 'after_save' do
    it 'sets up the watch in Elasticsearch' do
      expect(Es::ELK.client_reader.xpack.watcher).
        to receive(:put_watch).with(id: 123, body: 'body')
      observer.after_save(watcher)
    end
  end

  describe 'after_destroy' do
    it 'deletes the watch in Elasticsearch' do
      expect(Es::ELK.client_reader.xpack.watcher).
        to receive(:delete_watch).with(id: 123)
      observer.after_destroy(watcher)
    end
  end
end
