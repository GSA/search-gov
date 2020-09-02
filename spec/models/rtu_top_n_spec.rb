require 'spec_helper'

describe RtuTopN do
  let(:rtu_top_n) do
    RtuTopN.new('an ES query body', false, Date.new(2019, 1, 1))
  end

  describe '#top_n' do
    subject(:top_n) { rtu_top_n.top_n }
    let(:query_args) do
      {
        index: 'logstash-2019.01.01',
        body: 'an ES query body',
        size: 10_000
      }
    end

    it 'queries Elasticsearch with the expected args' do
      expect(ES::ELK.client_reader).to receive(:search).
        with(query_args).and_return({})
      top_n
    end

    context 'when the search fails' do
      before do
        allow(ES::ELK.client_reader).to receive(:search).
          and_raise(StandardError, 'search failure')
      end

      it 'returns an empty array' do
        expect(top_n).to eq([])
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).
          with(/Error querying top_n data: search failure/)
        top_n
      end
    end
  end
end
