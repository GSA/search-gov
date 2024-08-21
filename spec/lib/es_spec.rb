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

      it 'uses the values from the .env analytics[elasticsearch][reader] entry' do
        expect(host[:host]).to eq(URI(ENV.fetch('ES_READER_HOSTS').split(',').first).host)
        expect(host[:user]).to eq(ENV.fetch('ES_USER'))
      end

      it_behaves_like 'an Elasticsearch client'
    end

    describe '.client_writers' do
      subject(:client_writers) { Es::ELK.client_writers }

      let(:client) { client_writers.first }

      it 'uses the value(s) from the .env analytics[elasticsearch][writers] entry' do
        count = Rails.application.config.secret_keys.dig(:analytics, :elasticsearch, :writers).count
        expect(client_writers.size).to eq(count)
        count.times do |i|
          host = client.transport.hosts[i]
          expect(host[:host]).to eq(URI(ENV.fetch('ES_WRITERS_HOSTS').split(',').first).host)
          expect(host[:user]).to eq(ENV.fetch('ES_USER'))
        end
      end

      it 'freezes the secrets' do
        client_writers
        expect(Rails.application.config.secret_keys.dig(:analytics, :elasticsearch, :writers)).to be_frozen
      end

      it_behaves_like 'an Elasticsearch client'
    end
  end

  describe 'when working in Es::CustomIndices submodule' do
    describe '.client_reader' do
      let(:client) { Es::CustomIndices.client_reader }
      let(:host) { client.transport.hosts.first }

      it 'uses the values from the .env custom_indices[elasticsearch][reader] entry' do
        expect(host[:host]).to eq(URI(ENV.fetch('ES_READER_HOSTS').split(',').first).host)
        expect(host[:user]).to eq(ENV.fetch('ES_USER'))
      end

      it_behaves_like 'an Elasticsearch client'
    end

    describe '.client_writers' do
      let(:client) { Es::CustomIndices.client_writers.first }

      it 'uses the value(s) from the .env custom_indices[elasticsearch][writers] entry' do
        count = Rails.application.config.secret_keys.dig(:custom_indices, :elasticsearch, :writers).count
        expect(Es::CustomIndices.client_writers.size).to eq(count)
        count.times do |i|
          host = client.transport.hosts[i]
          expect(host[:host]).to eq(URI(ENV.fetch('ES_WRITERS_HOSTS').split(',').first).host)
          expect(host[:user]).to eq(ENV.fetch('ES_USER'))
        end
      end

      it 'freezes the secrets' do
        Es::CustomIndices.client_writers
        expect(Rails.application.config.secret_keys.dig(:custom_indices, :elasticsearch, :writers)).to be_frozen
      end

      it_behaves_like 'an Elasticsearch client'
    end
  end
end
