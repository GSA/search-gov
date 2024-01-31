require 'spec_helper'

describe Api::DocsSearchOptions do
  describe '.new' do
    subject { described_class.new(params) }

    context 'when an api_key is provided' do
      let(:params) { { api_key: 'client key' } }

      its(:api_key) { should == 'client key' }
    end
  end

  describe '#valid?' do
    context 'when dc is not present' do
      subject(:options) { described_class.new }

      it 'has error messages' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('dc must be present')
      end
    end
  end
end

