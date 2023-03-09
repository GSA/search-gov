# frozen_string_literal: true

describe Redactor do
  describe '.redact' do
    subject(:redact) { described_class.redact(string) }

    context 'when the string is nil' do
      let(:string) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the string does not contain sensitive information' do
      let(:string) { 'foo' }

      it { is_expected.to eq 'foo' }
    end

    context 'when the string may contain a social security number' do
      let(:string) { 'foo 123-45-6789 bar' }

      it { is_expected.to eq 'foo REDACTED_SSN bar' }

      context 'when the spaces have been URI-encoded' do
        let(:string) { '123+45+6789' }

        it { is_expected.to eq 'REDACTED_SSN' }
      end
    end

    context 'when the string contains an email address' do
      let(:string) { 'foo foo@bar.gov bar' }

      it { is_expected.to eq 'foo REDACTED_EMAIL bar' }

      context 'when the email address is URI-encoded' do
        let(:string) { 'foo%40bar.gov' }

        it { is_expected.to eq 'REDACTED_EMAIL' }
      end
    end

    context 'when the string may contain a credit card number', pending: 'SRCH-3918' do
      let(:string) { 'foo 1234567812345678 bar' }

      it { is_expected.to eq 'foo REDACTED_CC bar' }

      context 'when the spaces have been URI-encoded' do
        let(:string) { '1234+5678+1234+5678' }

        it { is_expected.to eq 'REDACTED_CC' }
      end
    end

    context 'when the string may contain a phone number', pending: 'SRCH-3919' do
      let(:string) { 'foo (800)555-1234 bar' }

      it { is_expected.to eq 'foo REDACTED_PHONE bar' }
    end
  end
end
