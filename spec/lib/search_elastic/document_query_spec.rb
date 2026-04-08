# frozen_string_literal: true

require 'spec_helper'

describe SearchElastic::DocumentQuery do
  fixtures :affiliates
  let(:query) { 'test' }
  let(:options) do
    { query: query }
  end
  let(:affiliate) { affiliates(:searchgov_affiliate) }
  let(:document_query) { described_class.new(options, affiliate:) }
  let(:body) { document_query.body.to_hash }

  describe '#body' do
    context 'when a query includes stopwords' do
      let(:suggestion_hash) { body[:suggest][:suggestion] }
      let(:query) { 'this document IS about the theater' }

      it 'strips the stopwords from the query' do
        expect(suggestion_hash[:text]).to eq 'document about theater'
      end

      it 'preserves meaningful words' do
        expect(suggestion_hash[:text]).to include('document', 'about', 'theater')
      end
    end

    context 'when aggregations are present' do
      it 'contains all required aggregation fields' do
        expect(body[:aggregations]).to match(
          hash_including(:audience,
                        :changed,
                        :content_type,
                        :created,
                        :mime_type,
                        :searchgov_custom1,
                        :searchgov_custom2,
                        :searchgov_custom3,
                        :tags)
        )
      end

      it 'has correct types for aggregation fields' do
        aggregations = body[:aggregations]
        expect(aggregations[:audience]).to be_a(Hash)
        expect(aggregations[:content_type]).to be_a(Hash)
        expect(aggregations[:created]).to be_a(Hash)
      end
    end

    context 'when the query is blank' do
      let(:query) { '' }

      it 'does not contain aggregations' do
        expect(body[:aggregations]).to be_nil
      end

      it 'maintains a valid body structure' do
        expect(body).to be_a(Hash)
        expect(body).not_to be_empty
      end
    end

    context 'when a query runs' do
      it 'includes scoring functions' do
        functions = body.dig(:query, :function_score, :functions)
        expect(functions).to be_an(Array)
        expect(functions).not_to be_empty
        expect(functions[0]).to eq(gauss: {
          changed: {
            origin: 'now',
            scale: '1825d',
            offset: '30d',
            decay: 0.3
          }
        })
        expect(functions[1]).to eq(filter: {
          terms: {
            extension: %w[doc docx pdf ppt pptx xls xlsx]
          }
        }, weight: '.75'
        )
        expect(functions[2]).to eq(field_value_factor: {
          field: 'click_count',
          modifier: 'log1p',
          factor: 2,
          missing: 1
        })
        expect(functions[3]).to eq(field_value_factor: {
          field: 'dap_domain_visits_count',
          modifier: 'log2p',
          factor: 2,
          missing: 0
        })
      end
    end
  end
end
