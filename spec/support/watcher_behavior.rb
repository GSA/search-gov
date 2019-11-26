shared_examples_for 'a watcher' do
  let(:put_watcher) do
    ES::ELK.client_reader.xpack.watcher.put_watch(id: watcher.id, body: watcher.body)
  end
  let(:delete_watcher) do
    ES::ELK.client_reader.xpack.watcher.delete_watch(id: watcher.id)
  end

  before do
    allow(watcher).to receive(:id).and_return(123)
  end

  describe '#body' do
    subject(:body) { watcher.body }

    it { is_expected.to eq(expected_body) }
  end

  describe 'creating a watcher' do
    after { delete_watcher }

    it 'can be added to Elasticsearch' do
      expect { put_watcher }.not_to raise_error
    end
  end

  describe 'executing a watcher' do
    before { put_watcher }

    after { delete_watcher }

    let(:execute_watcher) do
      ES::ELK.client_reader.xpack.watcher.execute_watch(id: watcher.id)
    end

    it 'is successful' do
      expect(execute_watcher['watch_record']['state']).not_to eq('failed')
      expect(execute_watcher['watch_record'].keys).not_to include('exception')
    end
  end
end
