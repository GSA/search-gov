require 'spec_helper'

describe Api::GssSearchOptions do
  describe '#valid?' do
    context 'when api_key and cx are not present' do
      subject(:options) { described_class.new }

      it 'has error messages' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('api_key must be present')
        expect(options.errors.full_messages).to include('cx must be present')
      end
    end
  end

  describe '#api_key' do
    subject { described_class.new({ affiliate: :affiliate_name, api_key: api_key }) }
    let(:api_key) { :api_key }
    let(:affiliate) { nil }
    before { allow(Affiliate).to receive(:find_by_name).with(:affiliate_name).and_return(affiliate) }

    context 'when the given affiliate does not exist' do
      it 'returns the given api_key' do
        expect(subject.api_key).to eql(api_key)
      end
    end

    context 'when the given affiliate exists' do
      let(:affiliate) { mock_model(Affiliate, bing_v5_key: bing_v5_key) }
      let(:bing_v5_key) { nil }

      context 'but it does not have a bing_v5_key set' do
        it 'returns the given api_key' do
          expect(subject.api_key).to eql(api_key)
        end
      end

      context 'and it has a bing_v5_key stored for that affiliate' do
        let(:bing_v5_key) { :bing_v5_key }

        it 'returns the bing_v5_key stored for that affiliate' do
          expect(subject.api_key).to eql(api_key)
        end
      end
    end
  end
end
