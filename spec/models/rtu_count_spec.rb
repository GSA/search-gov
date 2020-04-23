require 'spec_helper'

describe RtuCount do
  describe '.count' do
    subject(:count) do
      RtuCount.count('logstash*', 'query_body')
    end

    it 'extracts the count of documents' do
      expect(ES::ELK.client_reader).to receive(:count).
        with(index: 'logstash*', body: 'query_body')
      count
    end

    context 'when an error is raised' do
      before do
        allow(ES::ELK.client_reader).to receive(:count).
          and_raise(StandardError, 'something went wrong')
      end

      it 'returns nil' do
        expect(count).to eq(nil)
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).
          with(/something went wrong/)
        count
      end
    end
  end
end
