shared_examples_for 'a logstash query' do
  describe '#body' do
    subject(:body) { query.body }

    it 'does not raise an error' do
      ES::ELK.client_reader.search(index: 'logstash-*',  body: body)
    end

    it { is_expected.to eq(expected_body) }
  end
end
