# frozen_string_literal: true

require 'spec_helper'

describe 'Zeitwerk compliance' do
  it 'eager loads all files without errors' do
    Rails.application.eager_load!
  rescue NameError => e
    raise <<~MESSAGE
      Zeitwerk eager loading failed: #{e.message}

      Run `bin/rails zeitwerk:check` for more details on the naming violation.
    MESSAGE
  end
end
