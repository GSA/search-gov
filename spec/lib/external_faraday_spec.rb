require 'spec_helper'

describe ExternalFaraday do
  context '#get_config' do
    context 'when namespaced config is present' do
      it 'contains values for adapter and options' do
        expect(described_class.get_config('azure_web_api')[:adapter]).to eq(:typhoeus)
        expect(described_class.get_config('azure_web_api')[:options]).to be_present
      end
    end
  end
end
