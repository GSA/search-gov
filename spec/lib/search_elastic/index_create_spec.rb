# frozen_string_literal: true

require 'spec_helper'

describe SearchElastic::IndexCreate do
  let(:index_name) { 'test-index' }
  let(:shards) { 1 }
  let(:replicas) { 1 }
  let(:indices) { double('indices') }
  let(:client) { double('client', indices: indices) }

  describe '#initialize' do
    it 'accepts OPENSEARCH as service_name' do
      expect {
        described_class.new(service_name: 'OPENSEARCH', index_name: index_name, shards: shards, replicas: replicas)
      }.not_to raise_error
    end

    it 'accepts ELASTICSEARCH as service_name' do
      expect {
        described_class.new(service_name: 'ELASTICSEARCH', index_name: index_name, shards: shards, replicas: replicas)
      }.not_to raise_error
    end

    it 'raises ArgumentError for invalid service_name' do
      expect {
        described_class.new(service_name: 'INVALID', index_name: index_name, shards: shards, replicas: replicas)
      }.to raise_error(ArgumentError, /must be 'ELASTICSEARCH' or 'OPENSEARCH'/)
    end
  end

  describe '#create_or_update_index' do
    subject(:creator) do
      described_class.new(service_name: 'OPENSEARCH', index_name: index_name, shards: shards, replicas: replicas)
    end

    before do
      allow(indices).to receive(:put_template)
    end

    context 'when the index does not exist' do
      before do
        allow(indices).to receive(:exists?).with(index: index_name).and_return(false)
        allow(indices).to receive(:create)
      end

      it 'puts the template' do
        creator.create_or_update_index(client)

        expect(indices).to have_received(:put_template).with(
          name: index_name,
          body: hash_including('settings', 'mappings')
        )
      end

      it 'creates the index with settings and mappings' do
        creator.create_or_update_index(client)

        expect(indices).to have_received(:create).with(
          index: index_name,
          body: hash_including(
            settings: hash_including('analysis'),
            mappings: hash_including('dynamic_templates', 'properties')
          )
        )
      end
    end

    context 'when the index already exists' do
      before do
        allow(indices).to receive(:exists?).with(index: index_name).and_return(true)
        allow(indices).to receive(:put_mapping)
        allow(indices).to receive(:put_settings)
        allow(indices).to receive(:create)
      end

      it 'updates the mapping instead of creating' do
        creator.create_or_update_index(client)

        expect(indices).to have_received(:put_mapping).with(
          index: index_name,
          body: hash_including('dynamic_templates', 'properties')
        )
        expect(indices).not_to have_received(:create)
      end

      it 'updates replicas via put_settings' do
        creator.create_or_update_index(client)

        expect(indices).to have_received(:put_settings).with(
          index: index_name,
          body: { index: { 'number_of_replicas' => replicas } }
        )
      end
    end

    context 'when put_mapping raises a mapper_parsing_exception' do
      before do
        allow(indices).to receive(:exists?).with(index: index_name).and_return(true)
        allow(indices).to receive(:put_mapping).and_raise(
          Elasticsearch::Transport::Transport::Errors::BadRequest.new('[400] mapper_parsing_exception')
        )
      end

      it 'logs a warning and does not raise' do
        expect { creator.create_or_update_index(client) }.not_to raise_error
      end
    end

    context 'when put_settings fails' do
      before do
        allow(indices).to receive(:exists?).with(index: index_name).and_return(true)
        allow(indices).to receive(:put_mapping)
        allow(indices).to receive(:put_settings).and_raise(RuntimeError, 'settings error')
      end

      it 'logs a warning and does not raise' do
        expect { creator.create_or_update_index(client) }.not_to raise_error
      end
    end
  end
end
