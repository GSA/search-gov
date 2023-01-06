shared_examples_for 'a watcher' do
  let(:put_watcher) do
    Es::ELK.client_reader.xpack.watcher.put_watch(id: watcher.id, body: watcher.body)
  end
  let(:delete_watcher) do
    Es::ELK.client_reader.xpack.watcher.delete_watch(id: watcher.id)
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
  end

  before do
    allow(watcher).to receive(:id).and_return(123)
  end

  describe '#body' do
    subject(:body) { watcher.body }

    it 'returns a JSON structure representing an Elasticsearch Watcher body' do
      expect(body).to eq(expected_body)
    end
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
      Es::ELK.client_reader.xpack.watcher.execute_watch(id: watcher.id)
    end

    it 'is successful' do
      expect(execute_watcher['watch_record']['state']).not_to eq('failed')
      expect(execute_watcher['watch_record'].keys).not_to include('exception')
    end
  end

  # The conditions column is a JSON column that will return a hash with string keys:
  # https://api.rubyonrails.org/classes/ActiveRecord/Store.html
  # However, the conditions should be accessed via the methods provided by `store_accessor`
  # in each subclass, rather than directly via the hash. These specs exist mostly as
  # signposts to help future debuggers.
  describe '.conditions' do
    subject(:conditions) { watcher.conditions }

    it { is_expected.to be_a Hash }

    it 'uses string keys' do
      expect(watcher.conditions.keys).to all be_a(String)
    end
  end
end
