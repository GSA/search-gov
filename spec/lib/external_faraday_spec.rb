require 'spec_helper'

describe ExternalFaraday do
  context '#get_config' do
    context 'when namespaced config is present' do
      it 'contains values for adapter and options' do
        expect(described_class.get_config('azure_web_api')[:adapter]).to eq(:typhoeus)
        expect(described_class.get_config('azure_web_api')[:options]).to be_present
      end
    end

    context 'when namespaced config is not present' do
      it 'contains values for adapter and options' do
        nonexistent = described_class.get_config('nonexistent')
        expect(described_class.get_config('some_other_api')['adapter']).to be_present
        expect(described_class.get_config('some_other_api')['adapter']).to eq(nonexistent['adapter'])
        expect(described_class.get_config('some_other_api')['options']).to be_present
        expect(described_class.get_config('some_other_api')['options']).to eq(nonexistent['options'])
      end
    end
  end
end
