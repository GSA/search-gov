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

    # CC examples drawn from: https://support.bluesnap.com/docs/test-credit-card-numbers
    context 'when the string may contain a Amex style credit card number' do
      let(:string) { 'foo 374245455400126 bar' }

      it { is_expected.to eq 'foo REDACTED_CC bar' }

      context 'when the spaces have been URI-encoded' do
        let(:string) { '3742+454554+00126' }

        it { is_expected.to eq 'REDACTED_CC' }
      end
    end

    context 'when the string may contain a Discover style credit card number' do
      let(:string) { 'foo 6011000991300009 bar' }

      it { is_expected.to eq 'foo REDACTED_CC bar' }

      context 'when the spaces have been URI-encoded' do
        let(:string) { '6011+0009+9130+0009' }

        it { is_expected.to eq 'REDACTED_CC' }
      end
    end

    context 'when the string may contain a MasterCard style credit card number' do
      let(:string) { 'foo 2223000048410010 bar' }

      it { is_expected.to eq 'foo REDACTED_CC bar' }

      context 'when the spaces have been URI-encoded' do
        let(:string) { '5425+2334+3010+9903' }

        it { is_expected.to eq 'REDACTED_CC' }
      end
    end

    context 'when the string may contain a Visa style credit card number' do
      let(:string) { 'foo 4263982640269299 bar' }

      it { is_expected.to eq 'foo REDACTED_CC bar' }

      context 'when the spaces have been URI-encoded' do
        let(:string) { '4263+9826+4026+9299' }

        it { is_expected.to eq 'REDACTED_CC' }
      end
    end

    context 'when the string may contain a phone number', pending: 'SRCH-3919' do
      let(:string) { 'foo (800)555-1234 bar' }

      it { is_expected.to eq 'foo REDACTED_PHONE bar' }
    end
  end
end
