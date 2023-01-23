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

    before { allow(Language).to receive(:find_by_code).with(language_code).and_return(language) }

    context 'when the specified language does not exist' do
      let(:language) { nil }

      its([:Market]) { should == "'en-US'" }
    end

    context 'when the specified language exists' do
      let(:language) { mock_model(Language, is_azure_supported: is_azure_supported, inferred_country_code: inferred_country_code) }
      let(:inferred_country_code) { nil }

      context 'but is not supported by azure' do
        let(:is_azure_supported) { false }

        its([:Market]) { should == "'en-US'" }
      end

      context 'and is supported by azure' do
        let(:is_azure_supported) { true }

        context 'but has no inferred country code' do
          its([:Market]) { should == "'en-US'" }
        end

        context 'and has an inferred country code' do
          let(:inferred_country_code) { 'DE' }

          its([:Market]) { should == "'de-DE'" }
        end
      end
    end
  end
end
