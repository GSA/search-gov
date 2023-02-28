# frozen_string_literal: true

describe Redactor do
  describe '.' do
    subject(:redact) { described_class.redact(string) }

    context 'when the string does not contain sensitive information' do
      let(:string) { 'foo' }

      it { is_expected.to eq 'foo' }
    end

    context 'when the string may contain a social security number' do
      let(:string) { 'foo 123-45-6789 bar' }

      it { is_expected.to eq 'foo [redacted_ssn] bar' }
    end

    context 'when the string contains an email address' do
      let(:string) { 'foo foo@bar.gov bar' }

      it { is_expected.to eq 'foo [redacted_email] bar' }
    end

    context 'when the string may contain a credit card number' do
      let(:string) { 'foo 1234567812345678 bar' }

      it { is_expected.to eq 'foo [redacted_cc] bar' }
    end

    context 'when the string may contain a phone number' do
      let(:string) { 'foo (800)555-1234 bar' }

      it { is_expected.to eq 'foo [redacted_phone] bar' }
    end
  end
end
