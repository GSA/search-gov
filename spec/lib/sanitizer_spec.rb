require 'spec_helper'

describe Sanitizer, '.sanitize' do
  subject(:sanitize) { Sanitizer.sanitize(string) }

  context 'when the string contains HTML tags' do
    let(:string) { '<b>foo  bar</b><script>baz</script>' }

    it 'sanitizes the string' do
      expect(sanitize).to eq 'foo bar'
    end
  end

  context 'when the string is nil' do
    let(:string) { nil }

    it { is_expected.to eq '' }
  end

  context 'when the string is not valid UTF-8' do
    let(:string) { "foo\xF3" }

    it 'gracefully handles it' do
      expect(sanitize).to be_nil
    end

    it 'logs the error' do
      expect(Rails.logger).to receive(:error).with(
        "Error sanitizing string foo\xF3: invalid byte sequence in UTF-8"
      )
      sanitize
    end
  end

  context 'when the string contains additional whitespace' do
    let(:string) { 'foo  bar' }

    it { is_expected.to eq 'foo bar' }
  end

  context 'when the string contains HTML entities' do
    let(:string) { 'foo &amp; bar & baz' }

    it 'encodes them by default' do
      expect(sanitize).to eq 'foo &amp; bar &amp; baz'
    end

    context 'when not encoding the entities' do
      let(:sanitize) { Sanitizer.sanitize(string, encode: false) }

      it 'does not encode them' do
        expect(sanitize).to eq 'foo & bar & baz'
      end
    end
  end
end
