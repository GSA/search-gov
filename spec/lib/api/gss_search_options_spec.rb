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
end
