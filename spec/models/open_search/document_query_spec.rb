# frozen_string_literal: true

require 'spec_helper'

describe OpenSearch::DocumentQuery do
  fixtures :affiliates
  let(:query) { 'test' }
  let(:options) do
    { query: query }
  end
  let(:affiliate) { affiliates(:searchgov_affiliate) }
  let(:document_query) { described_class.new(options, affiliate:) }
  let(:body) { document_query.body.to_hash }

  describe '#body' do
    let(:filter_bool) { body.dig(:query, :function_score, :query, :bool, :filter).first[:bool] }
    let(:must_clauses) do
      must = filter_bool[:must]
      must.is_a?(Array) ? must : [must]
    end
    let(:simple_query_string_fields) { document_query.boosted_fields }
    let(:word_form_shoulds) do
      must = body.dig(:query, :function_score, :query, :bool, :must)
      must_clauses = must.is_a?(Array) ? must : [must]
      prefer_matches = must_clauses.dig(0, :bool, :must)
      prefer_matches = [prefer_matches] unless prefer_matches.is_a?(Array)
      shoulds = prefer_matches.dig(0, :bool, :should)
      shoulds.is_a?(Array) ? shoulds : [shoulds]
    end

    context 'when the affiliate language is English' do
      let(:options) { { query: query, language: 'en' } }

      it 'includes PDFs regardless of detected language' do
        expect(must_clauses).to include(
          hash_including(
            bool: hash_including(
              minimum_should_match: 1,
              should: array_including(
                { term: { language: 'en' } },
                { term: { mime_type: 'application/pdf' } }
              )
            )
          )
        )
      end

      it 'searches wildcard title/description/content fields in simple_query_string' do
        expect(simple_query_string_fields).to eq(['title_*^2', 'description_*^1.5', 'content_*'])
      end

      it 'adds a common query for each language-analyzer locale and text field' do
        SearchElastic::Template::LANGUAGE_ANALYZER_LOCALES.each do |locale|
          described_class::TEXT_FIELDS.each do |field|
            expect(word_form_shoulds.to_s).to include(
              "#{field}_#{locale}",
              document_query.common_terms_hash.to_s
            )
          end
        end
      end

      it 'requests wildcard highlights so non-English PDF snippets can be returned' do
        highlight_fields = body.dig(:highlight, :fields).keys.map(&:to_s)
        expect(highlight_fields).to contain_exactly('title_*', 'description_*', 'content_*')
      end

      it 'includes wildcard source fields so non-English PDF titles are returned' do
        expect(body[:_source]).to include('title_*', 'language')
      end
    end

    context 'when the affiliate language is not English' do
      let(:affiliate) { affiliates(:spanish_affiliate) }
      let(:options) { { query: query, language: 'es' } }

      it 'filters only to the affiliate language' do
        expect(must_clauses).to include(term: { language: 'es' })
        expect(must_clauses.to_s).not_to include('application/pdf')
      end

      it 'searches only the affiliate language-suffixed fields' do
        expect(simple_query_string_fields).to eq(['title_es^2', 'description_es^1.5', 'content_es'])
        expect(word_form_shoulds.to_s).not_to include('application/pdf')
        expect(simple_query_string_fields).not_to include('title_en^2')
      end

      it 'highlights only the affiliate language-suffixed fields' do
        highlight_fields = body.dig(:highlight, :fields).keys.map(&:to_s)
        expect(highlight_fields).to contain_exactly('title_es', 'description_es', 'content_es')
      end

      it 'does not include wildcard source fields' do
        expect(body[:_source]).to include('title_es')
        expect(body[:_source]).not_to include('title_*')
      end
    end

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
        }, weight: '.75')
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
