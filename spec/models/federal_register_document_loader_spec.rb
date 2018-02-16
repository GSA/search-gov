require 'spec_helper'

describe FederalRegisterDocumentLoader do

  it_behaves_like 'a ResqueJobStats job'

  describe '.perform' do
    it 'loads documents' do
      mock_agency = mock_model(FederalRegisterAgency, id: 100)
      expect(FederalRegisterAgency).to receive(:find_by_id).and_return(mock_agency)

      expect(FederalRegisterDocumentData).to receive(:load_documents).
        with(mock_agency, load_all: true)

      FederalRegisterDocumentLoader.perform(100)
    end
  end
end
