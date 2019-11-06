shared_context 'querying logstash indexes' do
  subject(:body) { query.body }
end

shared_examples_for 'a logstash query' do
  it 'does not raise an error' do
    ES::ELK.client_reader.search(index: 'logstash-*',  body: body)
  end

  it { is_expected.to eq(expected_body) }
end
