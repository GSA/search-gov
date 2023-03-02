# frozen_string_literal: true

# This is a first-pass, low-tech approach to redacting PII from our logs.
# We will eventually move this to a gem so that our other Rails apps can leverage the code.
# We may also want to use gems such as 'redactor' or 'ruby_regex'.
module Redactor
  PATTERNS = {
    ssn: /\b\d{3}[-\sxX._]?\d{2}[-\sxX._]?\d{4}\b/,
    email: /[a-zA-Z0-9][-a-zA-Z0-9._]+(@|%40)[-a-zA-Z0-9]+\.+[a-zA-Z]{2,8}/,
    cc: /\b(?:\d[ -.]*?){13,17}\b/,
    phone: /\(?([2-9]\d{2})\)?[- .]?([2-9]\d{2}[- .]?\d{4})/
  }.freeze

  def self.redact(str)
    str = str.dup
    PATTERNS.each { |key, value| str.gsub!(value, "[redacted_#{key}]") }
    str
  end
end
