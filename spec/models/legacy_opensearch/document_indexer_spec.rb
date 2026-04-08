# frozen_string_literal: true

require 'spec_helper'

describe LegacyOpenSearch::DocumentIndexer do
  let(:client) { double('opensearch_client') }
  let(:index_name) { ENV.fetch('LEGACY_OPENSEARCH_INDEX') }

  before do
    allow(OpenSearchConfig).to receive(:search_client).and_return(client)
  end

  describe '.index' do
    let(:params) do
      {
        audience: 'Everyone',
        changed: '2024-01-15T12:00:00Z',
        content: 'Full page content here',
        content_type: 'article',
        created: '2024-01-01T00:00:00Z',
        description: 'A test document',
        document_id: 'abc123',
        handle: 'searchgov',
        thumbnail_url: 'https://example.gov/thumb.png',
        language: 'en',
        mime_type: 'text/html',
        path: 'https://www.example.gov/page.html',
        searchgov_custom1: 'custom, values',
        searchgov_custom2: nil,
        searchgov_custom3: nil,
        tags: 'tag1, tag2',
        title: 'Test Page Title'
      }
    end

    it 'calls client.index with the correct index, id, and serialized body' do
      expect(client).to receive(:index) do |args|
        expect(args[:index]).to eq(index_name)
        expect(args[:id]).to eq('abc123')
        expect(args[:body][:language]).to eq('en')
        expect(args[:body]['title_en']).to eq('Test Page Title')
        expect(args[:body]['content_en']).to eq('Full page content here')
        expect(args[:body]['description_en']).to eq('A test document')
        expect(args[:body]['audience']).to eq('everyone')
        expect(args[:body]['content_type']).to eq('article')
        expect(args[:body][:basename]).to eq('page')
        expect(args[:body][:extension]).to eq('html')
        expect(args[:body][:domain_name]).to eq('www.example.gov')
        expect(args[:body][:url_path]).to eq('/page.html')
        expect(args[:body]['tags']).to eq(%w[tag1 tag2])
        expect(args[:body]['searchgov_custom1']).to eq(%w[custom values])
      end

      described_class.index(params)
    end

    it 'strips handle from the indexed body' do
      expect(client).to receive(:index) do |args|
        expect(args[:body]).not_to have_key(:handle)
        expect(args[:body]).not_to have_key('handle')
      end

      described_class.index(params)
    end

    it 'strips document_id from the indexed body' do
      expect(client).to receive(:index) do |args|
        expect(args[:body]).not_to have_key(:document_id)
        expect(args[:body]).not_to have_key('document_id')
      end

      described_class.index(params)
    end

    it 'preserves language in the indexed body' do
      expect(client).to receive(:index) do |args|
        expect(args[:body][:language]).to eq('en')
      end

      described_class.index(params)
    end

    it 'sets created_at when not present in params' do
      freeze_time do
        expect(client).to receive(:index) do |args|
          expect(args[:body][:updated_at]).to be_within(1.second).of(Time.now.utc)
        end

        described_class.index(params)
      end
    end

    it 'preserves created_at when already present in params' do
      existing_time = Time.utc(2023, 6, 15, 10, 0, 0)
      params[:created_at] = existing_time

      expect(client).to receive(:index) do |args|
        expect(args[:body][:created_at]).to eq(existing_time)
      end

      described_class.index(params)
    end

    it 'does not mutate the original params hash' do
      original_params = params.dup
      allow(client).to receive(:index)

      described_class.index(params)

      expect(params).to eq(original_params)
    end

    context 'with Spanish language' do
      before { params[:language] = 'es' }

      it 'creates language-suffixed fields with es' do
        expect(client).to receive(:index) do |args|
          expect(args[:body]['title_es']).to eq('Test Page Title')
          expect(args[:body][:language]).to eq('es')
          expect(args[:body]).not_to have_key('title_en')
        end

        described_class.index(params)
      end
    end

    context 'with nil language' do
      before { params[:language] = nil }

      it 'defaults to en' do
        expect(client).to receive(:index) do |args|
          expect(args[:body]['title_en']).to eq('Test Page Title')
          expect(args[:body][:language]).to eq('en')
        end

        described_class.index(params)
      end
    end

    context 'with missing optional fields' do
      let(:sparse_params) do
        {
          document_id: 'sparse123',
          language: 'en',
          title: 'Minimal Document',
          path: 'https://www.example.gov/minimal'
        }
      end

      it 'indexes successfully without optional fields' do
        expect(client).to receive(:index) do |args|
          expect(args[:id]).to eq('sparse123')
          expect(args[:body]['title_en']).to eq('Minimal Document')
          expect(args[:body][:basename]).to eq('minimal')
        end

        described_class.index(sparse_params)
      end
    end

    context 'with pre-existing array fields' do
      before do
        params[:tags] = %w[already an array]
        params[:searchgov_custom1] = %w[pre split]
      end

      it 'passes arrays through unchanged' do
        expect(client).to receive(:index) do |args|
          expect(args[:body]['tags']).to eq(%w[already an array])
          expect(args[:body]['searchgov_custom1']).to eq(%w[pre split])
        end

        described_class.index(params)
      end
    end

    context 'with string-keyed params' do
      let(:string_params) do
        {
          'document_id' => 'string_keys',
          'language' => 'en',
          'title' => 'String Keys',
          'path' => 'https://example.gov/string',
          'handle' => 'searchgov'
        }
      end

      it 'handles string keys correctly' do
        expect(client).to receive(:index) do |args|
          expect(args[:id]).to eq('string_keys')
          expect(args[:body]['title_en']).to eq('String Keys')
        end

        described_class.index(string_params)
      end
    end

    context 'when document_id is blank' do
      before { params[:document_id] = nil }

      it 'raises DocumentIndexerError' do
        expect { described_class.index(params) }.to raise_error(
          described_class::DocumentIndexerError, 'document_id is required'
        )
      end

      it 'does not call the client' do
        expect(client).not_to receive(:index)
        described_class.index(params) rescue nil
      end
    end

    context 'when OpenSearch returns a conflict' do
      before do
        allow(client).to receive(:index).and_raise(
          Elasticsearch::Transport::Transport::Errors::Conflict.new('[409] conflict')
        )
      end

      it 'raises DuplicateID' do
        expect { described_class.index(params) }.to raise_error(
          described_class::DuplicateID
        )
      end
    end

    context 'when OpenSearch returns a transport error' do
      before do
        allow(client).to receive(:index).and_raise(
          Elasticsearch::Transport::Transport::Errors::ServiceUnavailable.new('[503] unavailable')
        )
      end

      it 'raises DocumentIndexerError' do
        expect { described_class.index(params) }.to raise_error(
          described_class::DocumentIndexerError
        )
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/Failed to index document abc123/)
        described_class.index(params) rescue nil
      end
    end
  end

  describe '.delete' do
    it 'calls client.delete with the correct index and id' do
      expect(client).to receive(:delete).with(
        index: index_name,
        id: 'doc_to_delete'
      )

      described_class.delete(document_id: 'doc_to_delete')
    end

    it 'accepts and ignores extra keyword arguments like handle' do
      expect(client).to receive(:delete).with(
        index: index_name,
        id: 'doc123'
      )

      described_class.delete(handle: 'searchgov', document_id: 'doc123')
    end

    context 'when the document is not found' do
      before do
        allow(client).to receive(:delete).and_raise(
          Elasticsearch::Transport::Transport::Errors::NotFound.new('[404] not found')
        )
      end

      it 'does not raise an error' do
        expect { described_class.delete(document_id: 'missing') }.not_to raise_error
      end

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with(/Document not found for deletion: missing/)
        described_class.delete(document_id: 'missing')
      end
    end

    context 'when OpenSearch returns a transport error' do
      before do
        allow(client).to receive(:delete).and_raise(
          Elasticsearch::Transport::Transport::Errors::ServiceUnavailable.new('[503] unavailable')
        )
      end

      it 'raises DocumentIndexerError' do
        expect { described_class.delete(document_id: 'doc123') }.to raise_error(
          described_class::DocumentIndexerError
        )
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/Failed to delete document doc123/)
        described_class.delete(document_id: 'doc123') rescue nil
      end
    end
  end
end
