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

      context 'when OPENSEARCH_APP_ENABLED is false' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('OPENSEARCH_APP_ENABLED').and_return('false')
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

        it_behaves_like 'an Elasticsearch client', context_type: :analytics
      end

      context 'when OPENSEARCH_APP_ENABLED is true' do
        # Since OPENSEARCH_APP_ENABLED=true is now the default in test environment,
        # these tests verify the actual OpenSearch behavior

        it 'returns the OPENSEARCH_ANALYTICS_CLIENT' do
          expect(Es::ELK.client_reader).to eq(OPENSEARCH_ANALYTICS_CLIENT)
        end

        it 'does not use the ElasticSearch client' do
          elasticsearch_client = Es::ELK.send(:initialize_client)
          expect(Es::ELK.client_reader).not_to eq(elasticsearch_client)
          expect(Es::ELK.client_reader).to eq(OPENSEARCH_ANALYTICS_CLIENT)
        end

        context 'when OPENSEARCH_ANALYTICS_CLIENT is not defined' do
          before do
            # Hide the constant by stubbing defined? to return false
            hide_const('OPENSEARCH_ANALYTICS_CLIENT')
          end

          after do
            # Restore the constant after the test
            OpenSearchConfig.reset!
          end

          it 'raises an error with a helpful message' do
            expect { Es::ELK.client_reader }.to raise_error(
              RuntimeError,
              /OPENSEARCH_ANALYTICS_CLIENT is not initialized/
            )
          end
        end
      end
    end

    describe '.client_writers' do
      subject(:client_writers) { Es::ELK.client_writers }

      let(:client) { client_writers.first }
      let(:host) { client.transport.hosts.first }

      it 'uses the correct configuration values based on OPENSEARCH_APP_ENABLED flag' do
        if OpenSearchConfig.enabled?
          expect(client_writers.size).to eq(1)
          expect(host[:host]).to eq(URI(ENV.fetch('OPENSEARCH_ANALYTICS_HOST')).host)
          expect(host[:user]).to eq(ENV.fetch('OPENSEARCH_ANALYTICS_USER'))
        else
          count = ENV.fetch('ES_HOSTS').split(',').count
          expect(client_writers.size).to eq(count)
          count.times do |i|
            host = client.transport.hosts[i]
            expect(host[:host]).to eq(URI(ENV.fetch('ES_HOSTS').split(',').first).host)
            expect(host[:user]).to eq(ENV.fetch('ES_USER'))
          end
        end
      end

      it_behaves_like 'an Elasticsearch client', context_type: :analytics
    end
  end

  # Es::CustomIndices always uses Elasticsearch (for deprecated custom indices)
  # OpenSearch-migrated models use their own client via use_opensearch? method
  describe 'when working in Es::CustomIndices submodule' do
    describe '.client_reader' do
      let(:client) { Es::CustomIndices.client_reader }
      let(:host) { client.transport.hosts.first }

      it 'always uses Elasticsearch configuration (ignores OPENSEARCH_APP_ENABLED)' do
        expect(host[:host]).to eq(URI(ENV.fetch('ES_HOSTS').split(',').first).host)
        expect(host[:user]).to eq(ENV.fetch('ES_USER'))
      end

      it_behaves_like 'an Elasticsearch client', force_elasticsearch: true
    end

    describe '.client_writers' do
      let(:client) { Es::CustomIndices.client_writers.first }
      let(:host) { client.transport.hosts.first }

      it 'always uses Elasticsearch configuration (ignores OPENSEARCH_APP_ENABLED)' do
        count = ENV.fetch('ES_HOSTS').split(',').count
        expect(Es::CustomIndices.client_writers.size).to eq(count)
        count.times do |i|
          host = client.transport.hosts[i]
          expect(host[:host]).to eq(URI(ENV.fetch('ES_HOSTS').split(',').first).host)
          expect(host[:user]).to eq(ENV.fetch('ES_USER'))
        end
      end

      it_behaves_like 'an Elasticsearch client', force_elasticsearch: true
    end
  end
end
