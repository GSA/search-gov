require 'spec_helper'

describe FederalRegisterDocumentLoader do
  describe '.perform' do
    it 'loads documents' do
      FederalRegisterDocumentData.should_receive(:load_documents).with(federal_register_agency_ids: [100])
      FederalRegisterDocumentLoader.perform(100)
    end
  end
end
