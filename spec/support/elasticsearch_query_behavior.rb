# frozen_string_literal: true

shared_examples_for 'an Elasticsearch query' do |index|
  describe '#body' do
    subject(:body) { query.body }

    # Sanity-check to confirm that the query structure is valid
    it 'does not raise an error' do
      expect do
        Es::ELK.client_reader.search(index: index, body: body)
      end.not_to raise_error
    end

    it { is_expected.to eq(expected_body) }
  end
end

shared_examples_for 'a logstash query' do
  it_behaves_like 'an Elasticsearch query', 'logstash-*'
end

shared_examples_for 'a watcher query' do
  describe '#body' do
    subject(:body) { query.body }

    it { is_expected.to eq(expected_body) }
  end
end
