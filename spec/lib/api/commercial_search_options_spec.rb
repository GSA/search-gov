require 'spec_helper'

describe Api::CommercialSearchOptions do
  describe '#valid?' do
    context 'when api_key is not present' do
      subject(:options) { described_class.new }

      it 'has error messages' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('api_key must be present')
      end
    end
  end

  describe '#api_key' do
    subject(:options) { described_class.new({ affiliate: :affiliate_name, api_key: api_key }) }

    let(:api_key) { :api_key }
    let(:affiliate) { nil }

    before { allow(Affiliate).to receive(:find_by_name).with(:affiliate_name).and_return(affiliate) }

    context 'when the given affiliate does not exist' do
      it 'returns the given api_key' do
        expect(options.api_key).to eql(api_key)
      end
    end
  end
end
