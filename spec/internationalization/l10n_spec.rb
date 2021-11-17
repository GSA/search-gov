# frozen_string_literal: true

describe 'localization files' do
  let(:non_es_en_yaml) { YAML.load_file('config/locales/non_es_en_template.yml')['non_es_en_template'] }

  non_es_en_yaml_files = Dir['config/locales/*.yml'] - [
    'config/locales/en.yml',
    'config/locales/es.yml',
    'config/locales/non_es_en_template.yml',
    'config/locales/dynamic_form.en.yml',
    'config/locales/authlogic.en.yml'
  ]
  non_es_en_yaml_files.each do |filename|
    it 'contains valid YAML' do
      YAML.load_file filename
    end

    it 'matches the filename locale to the namespace on line 1' do
      yaml = YAML.load_file filename
      expect(yaml).to have_key(File.basename(filename, '.yml'))
    end

    it 'contains a valid cdr_format field' do
      yaml = YAML.load_file filename
      locale = yaml[File.basename(filename, '.yml')]
      expect(locale['cdr_format']).to match(%r{%[mdY]/%[mdY]/%[mdY]}), "expected valid case-sensitive Latin characters for cdr_format in #{filename}"
    end

    it 'contains a valid date_format field' do
      yaml = YAML.load_file filename
      locale = yaml[File.basename(filename, '.yml')]
      expect(locale['searches']['news_search_options']['date_format']).to match(%r{(m|d|yyyy)/(m|d|yyyy)/(m|d|yyyy)}), "expected valid case-sensitive Latin characters for date_format in #{filename}"
    end

    it 'contains a valid slashes field' do
      yaml = YAML.load_file filename
      locale = yaml[File.basename(filename, '.yml')]
      expect(locale['date']['formats']['slashes']).to match(%r{%-?[mdY]/%-?[mdY]/%-?[mdY]}), "expected valid case-sensitive Latin characters for slashes in #{filename}"
    end

    it 'contains each entry from non-English/Spanish template file' do
      yaml = YAML.load_file filename
      locale_name = File.basename(filename, '.yml')
      @filename = filename
      template = {}
      template.store(locale_name, non_es_en_yaml)
      deep_compare_required_keys(template, yaml, [])
    end
  end

  def deep_compare_required_keys(h1, h2, path)
    diff = h1.keys - h2.keys
    expect(diff.any?).to be_falsey, "expected each entry from non-English/Spanish template file to exist in #{@filename}. Check #{diff} key in #{path}."
    h1.each_key do |key|
      h1[key].is_a?(Hash) && h2[key].is_a?(Hash) && deep_compare_required_keys(h1[key], h2[key], path + [key])
    end
  end

  def deep_compare_unneeded_keys(h1, h2, path)
    diff = h2.keys - h1.keys
    expect(diff.any?).to be_falsey, "not expecting any entries to exist in #{@filename} that are not in non-English/Spanish template file. Check #{diff} key in #{path}."
    h1.each_key do |key|
      h1[key].is_a?(Hash) && h2[key].is_a?(Hash) && deep_compare_unneeded_keys(h1[key], h2[key], path + [key])
    end
  end
end
