# frozen_string_literal: true

require 'spec_helper'

describe Es do
  context 'when working in Es submodules' do
    let(:elk_objs) { Array.new(3, Es::ELK.client_reader) }
    let(:ci_objs) { Array.new(3, Es::ELK.client_reader) }

    describe '.client_reader' do
      it 'returns a different object in different submodules' do
        expect(Es::ELK.client_reader).not_to eq(Es::CustomIndices.client_reader)
      end

      it 'returns the same object given successive invocations' do
        2.times do |i|
          expect(elk_objs[i]).to eq(elk_objs[i + 1])
          expect(ci_objs[i]).to eq(ci_objs[i + 1])
        end
      end
    end

    describe '.client_writers' do
      it 'returns a different object in different submodules' do
        expect(Es::ELK.client_writers).not_to eq(Es::CustomIndices.client_writers)
      end

      it 'returns the same object given successive invocations' do
        2.times do |i|
          expect(elk_objs[i]).to eq(elk_objs[i + 1])
          expect(ci_objs[i]).to eq(ci_objs[i + 1])
        end
      end
    end
  end

  context 'when working in Es::ELK submodule' do
    describe '.client_reader' do
      subject(:client) { Es::ELK.client_reader }

      let(:host) { client.transport.hosts.first }

      context 'when OPENSEARCH_ENABLED is false' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('OPENSEARCH_ENABLED').and_return('false')
          # Clear cached OpenSearch config
          OpenSearchConfig.reset!
          # Clear memoized client
          Es::ELK.instance_variable_set(:@client_reader, nil)
        end

        after do
          # Clear cached OpenSearch config
          OpenSearchConfig.reset!
          # Clear memoized client
          Es::ELK.instance_variable_set(:@client_reader, nil)
        end

        it 'uses the values from the .env analytics[elasticsearch][reader] entry' do
          expect(host[:host]).to eq(URI(ENV.fetch('ES_HOSTS').split(',').first).host)
          expect(host[:user]).to eq(ENV.fetch('ES_USER'))
        end

        it_behaves_like 'an Elasticsearch client'
      end

      context 'when OPENSEARCH_ENABLED is true' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('OPENSEARCH_ENABLED').and_return('true')
          # Clear cached OpenSearch config
          OpenSearchConfig.reset!
          # Clear memoized client
          Es::ELK.instance_variable_set(:@client_reader, nil)
        end

        after do
          # Clear cached OpenSearch config
          OpenSearchConfig.reset!
          # Clear memoized client
          Es::ELK.instance_variable_set(:@client_reader, nil)
        end

        context 'when OPENSEARCH_ANALYTICS_CLIENT is defined' do
          let(:mock_opensearch_client) { double('OpenSearchClient') }

          before do
            # Define the constant if it doesn't exist, or stub it if it does
            unless defined?(OPENSEARCH_ANALYTICS_CLIENT)
              stub_const('OPENSEARCH_ANALYTICS_CLIENT', mock_opensearch_client)
            else
              allow(Object).to receive(:const_defined?).with(:OPENSEARCH_ANALYTICS_CLIENT).and_return(true)
              stub_const('OPENSEARCH_ANALYTICS_CLIENT', mock_opensearch_client)
            end
          end

          it 'returns the OPENSEARCH_ANALYTICS_CLIENT' do
            expect(Es::ELK.client_reader).to eq(mock_opensearch_client)
          end

          it 'does not use the ElasticSearch client' do
            elasticsearch_client = Es::ELK.send(:initialize_client)
            expect(Es::ELK.client_reader).not_to eq(elasticsearch_client)
            expect(Es::ELK.client_reader).to eq(mock_opensearch_client)
          end
        end

        context 'when OPENSEARCH_ANALYTICS_CLIENT is not defined' do
          before do
            # Hide the constant by stubbing defined? to return false
            hide_const('OPENSEARCH_ANALYTICS_CLIENT')
          end

          it 'raises an error with a helpful message' do
            expect { Es::ELK.client_reader }.to raise_error(
              RuntimeError,
              /OPENSEARCH_ENABLED is true but OPENSEARCH_ANALYTICS_CLIENT is not initialized/
            )
          end
        end
      end
    end

    describe '.client_writers' do
      subject(:client_writers) { Es::ELK.client_writers }

      let(:client) { client_writers.first }

      it 'uses the value(s) from the .env analytics[elasticsearch][writers] entry' do
        count = ENV.fetch('ES_HOSTS').split(',').count
        expect(client_writers.size).to eq(count)
        count.times do |i|
          host = client.transport.hosts[i]
          expect(host[:host]).to eq(URI(ENV.fetch('ES_HOSTS').split(',').first).host)
          expect(host[:user]).to eq(ENV.fetch('ES_USER'))
        end
      end

      it_behaves_like 'an Elasticsearch client'
    end
  end

  describe 'when working in Es::CustomIndices submodule' do
    describe '.client_reader' do
      let(:client) { Es::CustomIndices.client_reader }
      let(:host) { client.transport.hosts.first }

      it 'uses the values from the .env custom_indices[elasticsearch][reader] entry' do
        expect(host[:host]).to eq(URI(ENV.fetch('ES_HOSTS').split(',').first).host)
        expect(host[:user]).to eq(ENV.fetch('ES_USER'))
      end

      it_behaves_like 'an Elasticsearch client'
    end

    describe '.client_writers' do
      let(:client) { Es::CustomIndices.client_writers.first }

      it 'uses the value(s) from the .env custom_indices[elasticsearch][writers] entry' do
        count = ENV.fetch('ES_HOSTS').split(',').count
        expect(Es::CustomIndices.client_writers.size).to eq(count)
        count.times do |i|
          host = client.transport.hosts[i]
          expect(host[:host]).to eq(URI(ENV.fetch('ES_HOSTS').split(',').first).host)
          expect(host[:user]).to eq(ENV.fetch('ES_USER'))
        end
      end

      it_behaves_like 'an Elasticsearch client'
    end
  end
end
