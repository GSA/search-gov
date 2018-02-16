require 'spec_helper'

describe Language do
  fixtures :languages, :affiliates
  it { is_expected.to have_many(:affiliates) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to validate_presence_of(:name) }

  describe '.bing_market_for_code' do
    subject(:get_market) { Language.bing_market_for_code(code) }
    let(:code) { 'tlh' }
    let(:language) { mock_model(Language, is_azure_supported: is_azure_supported, inferred_country_code: inferred_country_code) }
    let(:is_azure_supported) { true }
    let(:inferred_country_code) { 'Undiscovered' }
    before { allow(Language).to receive(:find_by_code).with(code).and_return(language) }

    context 'when no language corresponds to the given code' do
      let(:language) { nil }

      it 'defaults to en-US' do
        expect(get_market).to eq('en-US')
      end
    end

    context 'when a language corresponds to the given code' do
      context 'but it is not azure-supported' do
        let(:is_azure_supported) { false }

        it 'defaults to en-US' do
          expect(get_market).to eq('en-US')
        end
      end

      context 'and it is azure-supported' do
        context 'but it has no inferred country code' do
          let(:inferred_country_code) { nil }

          it 'defaults to en-US' do
            expect(get_market).to eq('en-US')
          end
        end

        context 'and it has an inferred country code' do
          it 'uses the language and inferred country code' do
            expect(get_market).to eq('tlh-Undiscovered')
          end
        end
      end
    end
  end
end
