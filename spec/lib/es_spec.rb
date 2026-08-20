# frozen_string_literal: true

require 'spec_helper'

describe Es do
  describe Es::ELK do
    describe '.client_reader' do
      it 'returns the OpenSearch analytics client' do
        expect(Es::ELK.client_reader).to eq(OPENSEARCH_ANALYTICS_CLIENT)
      end

      context 'when OPENSEARCH_ANALYTICS_CLIENT is not defined' do
        before { hide_const('OPENSEARCH_ANALYTICS_CLIENT') }

        it 'raises an error with a helpful message' do
          expect { Es::ELK.client_reader }.to raise_error(
            RuntimeError,
            /OPENSEARCH_ANALYTICS_CLIENT is not initialized/
          )
        end
      end
    end

    describe '.client_writers' do
      subject(:client_writers) { Es::ELK.client_writers }

      it 'returns a single-element array with the OpenSearch analytics client' do
        expect(client_writers).to eq([OPENSEARCH_ANALYTICS_CLIENT])
      end
    end
  end
end
