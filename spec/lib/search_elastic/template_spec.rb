# frozen_string_literal: true

require 'spec_helper'

describe SearchElastic::Template do
  subject(:template) { described_class.new('*test*', 1, 1) }

  let(:parsed_body) { JSON.parse(template.body) }
  let(:settings) { parsed_body['settings'] }
  let(:mappings) { parsed_body['mappings'] }
  let(:properties) { mappings['properties'] }
  let(:dynamic_templates) { mappings['dynamic_templates'] }
  let(:analyzers) { settings.dig('analysis', 'analyzer') }
  let(:tokenizers) { settings.dig('analysis', 'tokenizer') }
  let(:filters) { settings.dig('analysis', 'filter') }
  let(:char_filters) { settings.dig('analysis', 'char_filter') }

  describe '#body' do
    it 'returns valid JSON' do
      expect { JSON.parse(template.body) }.not_to raise_error
    end

    it 'includes the index_patterns' do
      expect(parsed_body['index_patterns']).to eq('*test*')
    end
  end

  describe 'settings' do
    it 'sets number_of_shards' do
      expect(settings.dig('index', 'number_of_shards')).to eq(1)
    end

    it 'sets number_of_replicas' do
      expect(settings.dig('index', 'number_of_replicas')).to eq(1)
    end

    it 'includes analysis section' do
      expect(settings['analysis']).to include('char_filter', 'filter', 'analyzer', 'tokenizer')
    end
  end

  describe 'char_filter' do
    it 'defines the quotes char_filter' do
      expect(char_filters['quotes']).to include('type' => 'mapping')
    end
  end

  describe 'tokenizers' do
    it 'defines kuromoji tokenizer' do
      expect(tokenizers['kuromoji']).to include('type' => 'kuromoji_tokenizer')
    end

    it 'defines url_path_tokenizer' do
      expect(tokenizers['url_path_tokenizer']).to include('type' => 'PathHierarchy')
    end

    it 'defines domain_name_tokenizer' do
      expect(tokenizers['domain_name_tokenizer']).to include(
        'type' => 'PathHierarchy',
        'delimiter' => '.',
        'reverse' => true
      )
    end
  end

  describe 'filters' do
    it 'defines bigrams_filter' do
      expect(filters['bigrams_filter']).to include('type' => 'shingle')
    end

    described_class::LIGHT_STEMMERS.each do |locale, language|
      it "defines #{locale}_stem_filter for #{language}" do
        expect(filters["#{locale}_stem_filter"]).to include(
          'type' => 'stemmer',
          'name' => "light_#{language}"
        )
      end
    end

    described_class::STANDARD_STEMMERS.each do |locale, language|
      it "defines #{locale}_stem_filter for #{language}" do
        expect(filters["#{locale}_stem_filter"]).to include(
          'type' => 'stemmer',
          'name' => language
        )
      end
    end

    it 'defines ja_pos_filter' do
      expect(filters['ja_pos_filter']).to include('type' => 'kuromoji_part_of_speech')
    end
  end

  describe 'analyzers' do
    described_class::GENERIC_ANALYZER_LOCALES.each do |locale|
      it "defines #{locale}_analyzer" do
        expect(analyzers["#{locale}_analyzer"]).to include(
          'type' => 'custom',
          'tokenizer' => 'icu_tokenizer'
        )
        expect(analyzers["#{locale}_analyzer"]['filter']).to include('icu_normalizer', "#{locale}_stem_filter", 'icu_folding')
      end
    end

    it 'defines fr_analyzer with elision filter' do
      expect(analyzers['fr_analyzer']['filter']).to include('elision', 'fr_stem_filter')
    end

    it 'defines ja_analyzer with kuromoji_tokenizer' do
      expect(analyzers['ja_analyzer']).to include('tokenizer' => 'kuromoji_tokenizer')
    end

    it 'defines ko_analyzer as cjk type' do
      expect(analyzers['ko_analyzer']).to include('type' => 'cjk')
    end

    it 'defines zh_analyzer with smartcn' do
      expect(analyzers['zh_analyzer']).to include('tokenizer' => 'smartcn_sentence')
    end

    it 'defines bigrams_analyzer' do
      expect(analyzers['bigrams_analyzer']['filter']).to include('bigrams_filter')
    end

    it 'defines url_path_analyzer' do
      expect(analyzers['url_path_analyzer']).to include('tokenizer' => 'url_path_tokenizer')
    end

    it 'defines domain_name_analyzer' do
      expect(analyzers['domain_name_analyzer']).to include('tokenizer' => 'domain_name_tokenizer')
    end

    it 'defines default analyzer with icu_tokenizer' do
      expect(analyzers['default']).to include(
        'type' => 'custom',
        'tokenizer' => 'icu_tokenizer'
      )
    end
  end

  describe 'properties' do
    context 'date fields used by DocumentQuery' do
      %w[updated created changed].each do |field|
        it "defines #{field} as date type" do
          expect(properties[field]).to include('type' => 'date')
        end
      end
    end

    context 'keyword fields used by DocumentQuery' do
      %w[audience content_type document_id extension thumbnail_url
         language mime_type path searchgov_custom1 searchgov_custom2
         searchgov_custom3 tags].each do |field|
        it "defines #{field} as keyword type" do
          expect(properties[field]).to include('type' => 'keyword')
        end
      end
    end

    it 'defines basename as text' do
      expect(properties['basename']).to include('type' => 'text')
    end

    it 'defines url_path with url_path_analyzer' do
      expect(properties['url_path']).to include(
        'type' => 'text',
        'analyzer' => 'url_path_analyzer'
      )
    end

    it 'defines domain_name with domain_name_analyzer and keyword sub-field' do
      expect(properties['domain_name']).to include(
        'type' => 'text',
        'analyzer' => 'domain_name_analyzer'
      )
      expect(properties['domain_name']['fields']).to include(
        'keyword' => { 'type' => 'keyword' }
      )
    end

    it 'defines promote as boolean' do
      expect(properties['promote']).to include('type' => 'boolean')
    end

    it 'defines bigrams with bigrams_analyzer' do
      expect(properties['bigrams']).to include(
        'type' => 'text',
        'analyzer' => 'bigrams_analyzer'
      )
    end

    it 'defines click_count as integer' do
      expect(properties['click_count']).to include('type' => 'integer')
    end
  end

  describe 'dynamic_templates' do
    let(:template_names) do
      dynamic_templates.flat_map(&:keys)
    end

    described_class::LANGUAGE_ANALYZER_LOCALES.each do |locale|
      it "includes a dynamic template for #{locale}" do
        expect(template_names).to include(locale.to_s)
      end
    end

    it 'includes string_fields catch-all template' do
      expect(template_names).to include('string_fields')
    end

    described_class::LANGUAGE_ANALYZER_LOCALES.each do |locale|
      it "maps *_#{locale} fields to #{locale}_analyzer with term_vector and copy_to bigrams" do
        lang_template = dynamic_templates.find { |t| t.key?(locale.to_s) }&.dig(locale.to_s)
        expect(lang_template).to include(
          'match' => "*_#{locale}",
          'match_mapping_type' => 'string'
        )
        expect(lang_template['mapping']).to include(
          'analyzer' => "#{locale}_analyzer",
          'type' => 'text',
          'term_vector' => 'with_positions_offsets',
          'copy_to' => 'bigrams'
        )
      end
    end
  end
end
