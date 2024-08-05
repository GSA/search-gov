require 'spec_helper'

describe RtuCount do
  describe '.count' do
    subject(:count) do
      described_class.count('logstash*', 'query_body')
    end

    it 'extracts the count of documents' do
      expect(Es::ELK.client_reader).to receive(:count).
        with(index: 'logstash*', body: 'query_body')
      count
    end

    context 'when an error is raised' do
      before do
        allow(Es::ELK.client_reader).to receive(:count).
          and_raise(StandardError, 'something went wrong')
        allow(Rails.logger).to receive(:error)
      end

      it 'returns nil' do
        expect(count).to eq(nil)
      end

      it 'logs the error' do
        count
        expect(Rails.logger).to have_received(:error).
          with('Error extracting RtuCount:', instance_of(StandardError))
      end
    end
  end
end
