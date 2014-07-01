require 'spec_helper'

describe FederalRegisterAgency do
  fixtures :federal_register_agencies, :agencies

  let(:fr_agency) { federal_register_agencies(:fr_irs) }

  context 'when deleting an existing FederalRegisterAgency that is mapped to Agency' do
    it 'does not modify agencies.federal_register_agency_id' do
      irs = agencies(:irs)
      fr_agency.agencies.to_a.should == [irs]

      fr_agency.destroy

      irs.federal_register_agency_id.should == fr_agency.id
    end
  end

  context '#load_documents' do
    context 'when documents are stale' do
      it 'enqueues FederalRegisterDocumentLoader' do
        fr_agency.last_load_documents_requested_at = 7.days.ago

        Resque.should_receive(:enqueue_with_priority).with(:high,
                                                           FederalRegisterDocumentLoader,
                                                           fr_agency.id)
        fr_agency.should_receive(:touch).with(:last_load_documents_requested_at)

        fr_agency.load_documents
      end
    end

    context 'when documents are fresh' do
      it 'skips FederalRegisterDocumentLoader' do
        fr_agency.last_load_documents_requested_at = Date.current

        Resque.should_not_receive(:enqueue_with_priority)

        fr_agency.load_documents
      end
    end
  end
end
