# frozen_string_literal: true

# NOTE: This file is excluded from Zeitwerk autoloading (see config/application.rb)
# because i18n-tasks gem is only available in development/test environments.

require 'i18n/tasks/scanners/file_scanner'

# Track i18n usage on ts and tsx files
class I18nJsxScanner < I18n::Tasks::Scanners::FileScanner
  include I18n::Tasks::Scanners::OccurrenceFromPosition

  def scan_file(path)
    text = read_file(path)
    text.scan(/i18n\.t\(["']([\w.]+)/).map do |match|
      raw_key = match.first.underscore
      # rubocop:disable Style/HashSyntax
      occurrence = occurrence_from_position(path, text, Regexp.last_match.offset(0).first, raw_key: raw_key)
      # rubocop:enable Style/HashSyntax

      [raw_key, occurrence]
    end
  end
end

I18n::Tasks.add_scanner('I18nJsxScanner', only: %w[*.ts *.tsx])
