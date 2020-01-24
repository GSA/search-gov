shared_examples_for 'a logstash query' do
  describe '#body' do
    subject(:body) { query.body }

    it 'does not raise an error' do
      expect {
        ES::ELK.client_reader.search(index: 'logstash-*',  body: body)
      }.not_to raise_error
    end

    it { is_expected.to eq(expected_body) }
  end
end

shared_examples_for 'a watcher query' do
  describe '#body' do
    subject(:body) { query.body }

    it { is_expected.to eq(expected_body) }
  end
end
