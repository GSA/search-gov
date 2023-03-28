# frozen_string_literal: true

# This is a first-pass, low-tech approach to redacting PII from our logs.
# We will eventually move this to a gem so that our other Rails apps can leverage the code.
# We may also want to use gems such as 'redactor' or 'ruby_regex'.
module Redactor
  PATTERNS = {
    ssn: /\b\d{3}[-\sxX._+]?\d{2}[-\sxX._+]?\d{4}\b/,
    email: /[a-zA-Z0-9][-a-zA-Z0-9._]+(@|%40)[-a-zA-Z0-9]+\.+[a-zA-Z]{2,8}/,
    phone: /(?:\+?1[-.\s+]?)?\(?\d{3}\)?[-.\s+]?\d{3}[-.\s+]?\d{4}\b/
  }.freeze

  def self.redact(str)
    return unless str

    str = str.dup
    PATTERNS.each { |key, value| str.gsub!(value, "REDACTED_#{key.to_s.upcase}") }
    str
  end
end
