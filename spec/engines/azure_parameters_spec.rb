require 'spec_helper'

describe AzureParameters do
  describe '#to_hash' do
    subject { described_class.new(options).to_hash }

    let(:options) do
      {
        language: language_code,
        query: 'searching'
      }
    end
    let(:language_code) { 'de' }

    before { allow(Language).to receive(:find_by).with(code: language_code).and_return(language) }

    context 'when the specified language does not exist' do
      let(:language) { nil }

      its([:Market]) { is_expected.to eq("'en-US'") }
    end

    context 'when the specified language exists' do
      let(:language) { mock_model(Language, inferred_country_code: inferred_country_code) }
      let(:inferred_country_code) { nil }

      context 'when there is no inferred country code' do
        its([:Market]) { is_expected.to eq("'en-US'") }
      end

      context 'when there is an inferred country code' do
        let(:inferred_country_code) { 'DE' }

        its([:Market]) { is_expected.to eq("'de-DE'") }
      end
    end
  end
end
