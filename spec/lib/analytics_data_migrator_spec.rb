# frozen_string_literal: true

require 'spec_helper'
require 'analytics_data_migrator'

describe AnalyticsDataMigrator do
  subject(:migrator) do
    described_class.new(
      start_date: start_date,
      end_date: end_date,
      dry_run: dry_run,
      logger: logger
    )
  end

  let(:start_date) { Date.new(2024, 1, 1) }
  let(:end_date) { Date.new(2024, 1, 3) }
  let(:logger) { instance_double(Logger, info: nil, error: nil) }

  let(:source_client) { instance_double(Elasticsearch::Client) }
  let(:destination_client) { instance_double(Elasticsearch::Client) }

  let(:source_indices) { instance_double(Elasticsearch::API::Indices::IndicesClient) }
  let(:destination_indices) { instance_double(Elasticsearch::API::Indices::IndicesClient) }

  before do
    allow(migrator).to receive(:source_client).and_return(source_client)
    allow(migrator).to receive(:destination_client).and_return(destination_client)
    allow(source_client).to receive(:indices).and_return(source_indices)
    allow(destination_client).to receive(:indices).and_return(destination_indices)
    allow(source_client).to receive(:ping).and_return(true)
    allow(source_client).to receive(:clear_scroll)
  end

  describe '#migrate' do
    context 'when dry_run is true' do
      let(:dry_run) { true }

      before do
        allow(source_indices).to receive(:exists?).and_return(true)
        allow(destination_indices).to receive(:exists?).and_return(false)
        allow(source_client).to receive(:search).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => { 'hits' => [{ '_id' => '1', '_source' => { 'query' => 'test' } }] }
        )
        allow(source_client).to receive(:scroll).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => { 'hits' => [] }
        )
      end

      it 'does not write to destination' do
        expect(destination_client).not_to receive(:bulk)
        expect(destination_indices).not_to receive(:create)
        migrator.migrate
      end

      it 'logs dry run mode' do
        expect(logger).to receive(:info).with(/DRY RUN MODE/)
        migrator.migrate
      end

      it 'returns document counts' do
        result = migrator.migrate
        expect(result[:migrated]).to be > 0
        expect(result[:errors]).to eq(0)
      end
    end

    context 'when dry_run is false' do
      let(:dry_run) { false }

      before do
        allow(source_indices).to receive(:exists?).and_return(true)
        allow(destination_indices).to receive(:exists?).and_return(true)
        allow(source_client).to receive(:search).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => { 'hits' => [{ '_id' => '1', '_source' => { 'query' => 'test' } }] }
        )
        allow(source_client).to receive(:scroll).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => { 'hits' => [] }
        )
        allow(destination_client).to receive(:bulk).and_return('errors' => false)
      end

      it 'writes documents to destination' do
        expect(destination_client).to receive(:bulk).at_least(:once)
        migrator.migrate
      end

      it 'returns migration results' do
        result = migrator.migrate
        expect(result).to have_key(:migrated)
        expect(result).to have_key(:errors)
      end
    end

    context 'when source index does not exist' do
      let(:dry_run) { false }

      before do
        allow(source_indices).to receive(:exists?).and_return(false)
      end

      it 'skips the index' do
        expect(source_client).not_to receive(:search)
        result = migrator.migrate
        expect(result[:migrated]).to eq(0)
      end
    end
  end

  describe '#migrate_index' do
    let(:dry_run) { false }
    let(:index_name) { 'logstash-2024.01.15' }

    context 'when index exists' do
      before do
        allow(source_indices).to receive(:exists?).with(index: index_name).and_return(true)
        allow(destination_indices).to receive(:exists?).with(index: index_name).and_return(true)
        allow(source_client).to receive(:search).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => {
            'hits' => [
              { '_id' => '1', '_source' => { 'query' => 'test1' } },
              { '_id' => '2', '_source' => { 'query' => 'test2' } }
            ]
          }
        )
        allow(source_client).to receive(:scroll).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => { 'hits' => [] }
        )
        allow(destination_client).to receive(:bulk).and_return('errors' => false)
      end

      it 'migrates documents from the index' do
        result = migrator.migrate_index(index_name)
        expect(result[:migrated]).to eq(2)
        expect(result[:errors]).to eq(0)
      end
    end

    context 'when bulk insert has errors' do
      before do
        allow(source_indices).to receive(:exists?).with(index: index_name).and_return(true)
        allow(destination_indices).to receive(:exists?).with(index: index_name).and_return(true)
        allow(source_client).to receive(:search).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => {
            'hits' => [
              { '_id' => '1', '_source' => { 'query' => 'test1' } },
              { '_id' => '2', '_source' => { 'query' => 'test2' } }
            ]
          }
        )
        allow(source_client).to receive(:scroll).and_return(
          '_scroll_id' => 'scroll123',
          'hits' => { 'hits' => [] }
        )
        allow(destination_client).to receive(:bulk).and_return(
          'errors' => true,
          'items' => [
            { 'index' => { 'status' => 201 } },
            { 'index' => { 'error' => { 'type' => 'mapper_parsing_exception' } } }
          ]
        )
      end

      it 'counts errors correctly' do
        result = migrator.migrate_index(index_name)
        expect(result[:migrated]).to eq(1)
        expect(result[:errors]).to eq(1)
      end
    end

    context 'when index does not exist' do
      before do
        allow(source_indices).to receive(:exists?).with(index: index_name).and_return(false)
      end

      it 'returns zero counts' do
        result = migrator.migrate_index(index_name)
        expect(result[:migrated]).to eq(0)
        expect(result[:errors]).to eq(0)
      end
    end
  end

  describe 'index creation' do
    let(:dry_run) { false }
    let(:index_name) { 'logstash-2024.01.15' }

    before do
      allow(source_indices).to receive(:exists?).with(index: index_name).and_return(true)
      allow(source_client).to receive(:search).and_return(
        '_scroll_id' => 'scroll123',
        'hits' => { 'hits' => [] }
      )
    end

    context 'when destination index already exists' do
      before do
        allow(destination_indices).to receive(:exists?).with(index: index_name).and_return(true)
      end

      it 'skips index creation' do
        expect(destination_indices).not_to receive(:create)
        expect(logger).to receive(:info).with(/already exists/)
        migrator.migrate_index(index_name)
      end
    end

    context 'when OpenSearch has composable index template' do
      before do
        allow(destination_indices).to receive(:exists?).with(index: index_name).and_return(false)
        allow(destination_indices).to receive(:get_index_template).with(name: 'logstash*').and_return(
          'index_templates' => [{ 'name' => 'logstash' }]
        )
        allow(destination_indices).to receive(:create)
      end

      it 'creates destination index using OpenSearch template' do
        expect(destination_indices).to receive(:create).with(index: index_name)
        migrator.migrate_index(index_name)
      end
    end

    context 'when OpenSearch has legacy template' do
      before do
        allow(destination_indices).to receive(:exists?).with(index: index_name).and_return(false)
        allow(destination_indices).to receive(:get_index_template).and_raise(StandardError)
        allow(destination_indices).to receive(:get_template).with(name: 'logstash*').and_return(
          'logstash_template' => { 'mappings' => {} }
        )
        allow(destination_indices).to receive(:create)
      end

      it 'creates destination index using legacy template' do
        expect(destination_indices).to receive(:create).with(index: index_name)
        migrator.migrate_index(index_name)
      end
    end

    context 'when OpenSearch has no index template' do
      before do
        allow(destination_indices).to receive(:exists?).with(index: index_name).and_return(false)
        allow(destination_indices).to receive(:get_index_template).and_raise(StandardError)
        allow(destination_indices).to receive(:get_template).and_raise(StandardError)
      end

      it 'logs an error and does not create index' do
        expect(logger).to receive(:error).with(/No logstash index template found/)
        expect(destination_indices).not_to receive(:create)
        migrator.migrate_index(index_name)
      end

      it 'skips migration and returns error count' do
        result = migrator.migrate_index(index_name)
        expect(result[:migrated]).to eq(0)
        expect(result[:errors]).to eq(1)
      end

      it 'does not attempt to migrate documents' do
        expect(source_client).not_to receive(:search)
        migrator.migrate_index(index_name)
      end
    end
  end
end
