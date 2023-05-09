# frozen_string_literal: true

# This spec file has been lightly updated from the default specs
# included with the i18n-tasks gem
# https://github.com/glebm/i18n-tasks#installation

require 'i18n/tasks'

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:missing_admin_keys) { i18n.missing_keys(**{ locales: %w[en], types: %w[used] }) }
  let(:unused_keys) { i18n.unused_keys }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it 'does not have missing keys' do
    pending('to be resolved by SRCH-2592')
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  it 'admin center file does not have missing keys' do
    error_message = "Missing #{missing_admin_keys.leaves.count} admin_center i18n keys, run " \
                    '`i18n-tasks missing -l en -t used` to show them.  Optionally, run ' \
                    '`i18n-tasks add-missing -l en` to automatically generate them.'
    expect(missing_admin_keys).to be_empty,
                                  error_message
  end

  it 'does not have unused keys' do
    expect(unused_keys).to be_empty,
                           "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
  end

  it 'files are normalized' do
    skip('our translations are organized by feature, not alphabetically')
    non_normalized = i18n.non_normalized_paths
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    "Please run `i18n-tasks normalize' to fix"
    expect(non_normalized).to be_empty, error_message
  end

  it 'admin center files are normalized' do
    non_normalized = i18n.non_normalized_paths.select { |p| p.include?('admin_center') }
    error_message = "The admin_center file needs to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    "Please run `i18n-tasks normalize -l en' to fix." \
                    "Do not commit changes to 'config/locales/en.yml' as those" \
                    'translations are organized by feature.'
    expect(non_normalized).to be_empty, error_message
  end

  it 'does not have inconsistent interpolations' do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Run `i18n-tasks check-consistent-interpolations' to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end
