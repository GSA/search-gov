# frozen_string_literal: true

require 'spec_helper'

describe CsvResponsive do
  let(:klass) { Class.new { extend CsvResponsive } }

  describe '.format_modules' do
    subject(:format_modules) { klass.format_modules(modules) }

    context 'when the modules are a string' do
      let(:modules) { 'FOO' }

      it { is_expected.to eq 'FOO' }
    end

    context 'when the modules are an array' do
      let(:modules) { %w[FOO BAR] }

      it { is_expected.to eq 'FOO BAR' }
    end
  end
end
