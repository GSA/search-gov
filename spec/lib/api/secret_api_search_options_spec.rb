require 'spec_helper'

describe Api::SecretApiSearchOptions do
  describe '#valid?' do
    context 'when sc_access_key is not present' do
      subject(:options) { described_class.new }

      it 'has error messages' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('sc_access_key must be present')
      end
    end

    context 'when sc_access_key does not match' do
      let(:SC_ACCESS_KEY) do
        'secureKey'
      end

      subject(:options) { described_class.new(sc_access_key: 'invalid') }

      it 'has the obfuscated error message' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('hidden_key is required')
      end
    end
  end
end
