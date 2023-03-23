# frozen_string_literal: true

# This is a first-pass, low-tech approach to redacting PII from our logs.
# We will eventually move this to a gem so that our other Rails apps can leverage the code.
# We may also want to use gems such as 'redactor' or 'ruby_regex'.
module Redactor
  PATTERNS = {
    ssn: /\b\d{3}[-\sxX._+]?\d{2}[-\sxX._+]?\d{4}\b/,
    email: /[a-zA-Z0-9][-a-zA-Z0-9._]+(@|%40)[-a-zA-Z0-9]+\.+[a-zA-Z]{2,8}/,
    cc: /\b(?:
      (3[47]\d{2}(?:[-+\s]{1})?\d{6}(?:[-+\s]{1})?\d{5}) | # AMEX
      (6(?:011|5\d{2})(?:[-+\s]{1})?\d{4}(?:[-+\s]{1})?\d{4}(?:[-+\s]{1})?\d{4}) | # Discover
      ((?:5[1-5]\d{2}|2[2-7]\d{2})(?:[-+\s]{1})?\d{4}(?:[-+\s]{1})?\d{4}(?:[-+\s]{1})?\d{4}) | # MasterCard
      (4\d{3}(?:[-+\s]{1})?\d{4}(?:[-+\s]{1})?\d{4}(?:[-+\s]{1})?\d{4}) # Visa
      )\b/mx
  }.freeze

  def self.redact(str)
    return unless str

    str = str.dup
    PATTERNS.each { |key, value| str.gsub!(value, "REDACTED_#{key.to_s.upcase}") }
    str
  end
end
