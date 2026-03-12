# frozen_string_literal: true

require 'spec_helper'

# Verifies that SearchElastic::Template (search-gov) is a superset of the
# i14y Documents template. This ensures the new legacy OpenSearch index can
# serve queries against migrated i14y data without missing fields or analyzers.
#
# The i14y fixture was generated from i14y's Documents.new.body and represents
# a point-in-time snapshot. If i14y's template changes, regenerate the fixture.
describe 'SearchElastic::Template parity with i14y Documents template' do
  let(:search_gov_body) { JSON.parse(SearchElastic::Template.new('*test*', 1, 1).body) }
  let(:i14y_body) { JSON.parse(Rails.root.join('spec/fixtures/json/i14y_documents_template.json').read) }

  let(:sg_properties) { search_gov_body.dig('mappings', 'properties') }
  let(:i14y_properties) { i14y_body.dig('mappings', 'properties') }

  let(:sg_analyzers) { search_gov_body.dig('settings', 'analysis', 'analyzer') }
  let(:i14y_analyzers) { i14y_body.dig('settings', 'analysis', 'analyzer') }

  let(:sg_tokenizers) { search_gov_body.dig('settings', 'analysis', 'tokenizer') }
  let(:i14y_tokenizers) { i14y_body.dig('settings', 'analysis', 'tokenizer') }

  let(:sg_filters) { search_gov_body.dig('settings', 'analysis', 'filter') }
  let(:i14y_filters) { i14y_body.dig('settings', 'analysis', 'filter') }

  let(:sg_char_filters) { search_gov_body.dig('settings', 'analysis', 'char_filter') }
  let(:i14y_char_filters) { i14y_body.dig('settings', 'analysis', 'char_filter') }

  let(:sg_dynamic_templates) { search_gov_body.dig('mappings', 'dynamic_templates') }
  let(:i14y_dynamic_templates) { i14y_body.dig('mappings', 'dynamic_templates') }

  describe 'field mappings' do
    it 'contains every i14y property field' do
      missing_fields = i14y_properties.keys - sg_properties.keys
      expect(missing_fields).to be_empty,
        "search-gov template is missing i14y fields: #{missing_fields.join(', ')}"
    end

    it 'matches field types for all shared properties' do
      mismatched = {}
      i14y_properties.each do |field, i14y_mapping|
        sg_mapping = sg_properties[field]
        next unless sg_mapping

        if i14y_mapping['type'] != sg_mapping['type']
          mismatched[field] = { i14y: i14y_mapping['type'], search_gov: sg_mapping['type'] }
        end
      end
      expect(mismatched).to be_empty,
        "Field type mismatches: #{mismatched.inspect}"
    end

    it 'matches analyzers for all shared properties' do
      mismatched = {}
      i14y_properties.each do |field, i14y_mapping|
        sg_mapping = sg_properties[field]
        next unless sg_mapping

        if i14y_mapping['analyzer'] != sg_mapping['analyzer']
          mismatched[field] = { i14y: i14y_mapping['analyzer'], search_gov: sg_mapping['analyzer'] }
        end
      end
      expect(mismatched).to be_empty,
        "Analyzer mismatches: #{mismatched.inspect}"
    end
  end

  describe 'dynamic templates' do
    let(:sg_template_names) { sg_dynamic_templates.flat_map(&:keys) }
    let(:i14y_template_names) { i14y_dynamic_templates.flat_map(&:keys) }

    it 'contains every i14y dynamic template' do
      missing = i14y_template_names - sg_template_names
      expect(missing).to be_empty,
        "search-gov template is missing dynamic templates: #{missing.join(', ')}"
    end

    it 'matches dynamic template configurations' do
      i14y_dynamic_templates.each do |i14y_tmpl|
        name = i14y_tmpl.keys.first
        sg_tmpl = sg_dynamic_templates.find { |t| t.key?(name) }
        next unless sg_tmpl

        expect(sg_tmpl[name]['match']).to eq(i14y_tmpl[name]['match']),
          "Dynamic template '#{name}' match pattern differs"
        expect(sg_tmpl[name]['mapping']['analyzer']).to eq(i14y_tmpl[name]['mapping']['analyzer']),
          "Dynamic template '#{name}' analyzer differs"
        expect(sg_tmpl[name]['mapping']['type']).to eq(i14y_tmpl[name]['mapping']['type']),
          "Dynamic template '#{name}' type differs"
      end
    end
  end

  describe 'analyzers' do
    it 'contains every i14y analyzer' do
      missing = i14y_analyzers.keys - sg_analyzers.keys
      expect(missing).to be_empty,
        "search-gov template is missing analyzers: #{missing.join(', ')}"
    end

    it 'matches analyzer configurations (type and tokenizer)' do
      mismatched = {}
      i14y_analyzers.each do |name, i14y_config|
        sg_config = sg_analyzers[name]
        next unless sg_config

        if i14y_config['type'] != sg_config['type'] || i14y_config['tokenizer'] != sg_config['tokenizer']
          mismatched[name] = { i14y: i14y_config, search_gov: sg_config }
        end
      end
      expect(mismatched).to be_empty,
        "Analyzer config mismatches: #{mismatched.inspect}"
    end
  end

  describe 'tokenizers' do
    it 'contains every i14y tokenizer' do
      missing = i14y_tokenizers.keys - sg_tokenizers.keys
      expect(missing).to be_empty,
        "search-gov template is missing tokenizers: #{missing.join(', ')}"
    end
  end

  describe 'char_filters' do
    it 'contains every i14y char_filter' do
      missing = i14y_char_filters.keys - sg_char_filters.keys
      expect(missing).to be_empty,
        "search-gov template is missing char_filters: #{missing.join(', ')}"
    end
  end

  describe 'stemmers and filters' do
    it 'contains every i14y stemmer filter' do
      i14y_stemmers = i14y_filters.select { |_, v| v['type'] == 'stemmer' }
      sg_stemmers = sg_filters.select { |_, v| v['type'] == 'stemmer' }

      missing = i14y_stemmers.keys - sg_stemmers.keys
      expect(missing).to be_empty,
        "search-gov template is missing stemmer filters: #{missing.join(', ')}"
    end

    it 'matches stemmer configurations' do
      i14y_stemmers = i14y_filters.select { |_, v| v['type'] == 'stemmer' }

      i14y_stemmers.each do |name, i14y_config|
        sg_config = sg_filters[name]
        expect(sg_config['name']).to eq(i14y_config['name']),
          "Stemmer '#{name}' language differs: search-gov=#{sg_config['name']}, i14y=#{i14y_config['name']}"
      end
    end
  end

  describe 'documented differences' do
    it 'search-gov includes number_of_shards/replicas (i14y does not)' do
      expect(search_gov_body.dig('settings', 'index', 'number_of_shards')).to be_present
      expect(i14y_body.dig('settings', 'index')).to be_nil
    end

    it 'search-gov includes domain_name.keyword sub-field (i14y does not)' do
      expect(sg_properties.dig('domain_name', 'fields', 'keyword')).to be_present
      expect(i14y_properties.dig('domain_name', 'fields')).to be_nil
    end

    it 'search-gov does not include synonym/protword filters (i14y does)' do
      expect(sg_filters.keys).not_to include('en_synonym', 'en_protected_filter')
      expect(i14y_filters.keys).to include('en_synonym', 'en_protected_filter')
    end
  end
end
