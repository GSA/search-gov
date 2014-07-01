require 'spec_helper'

describe FederalRegisterDocumentData do
  let(:fake_options) { mock('options') }

  describe '.import' do
    it 'destroys obsolete documents' do
      FederalRegisterDocument.should_receive(:pluck).with(:id).and_return([100, 200, 300])
      FederalRegisterDocumentData.should_receive(:load_documents).and_return([200, 199, 299])
      FederalRegisterDocument.should_receive(:destroy).with([100, 300])

      FederalRegisterDocumentData.import
    end
  end

  describe '.load_documents' do
    let(:parser) { mock(FederalRegisterDocumentApiParser) }

    let(:document_1_attributes) do
      { document_number: '2014-15054',
        document_type: 'Notice',
        html_url: 'https://www.federalregister.gov/articles/2014/06/27/2014-15054/commission-to-eliminate-child-abuse',
        publication_date: Date.parse('2014-06-27'),
        title: 'Commission To Eliminate Child Abuse and Neglect Fatalities; Announcement of Meeting' }
    end

    let(:document_2_attributes) do
      { document_number: '2014-14703',
        document_type: 'Proposed Rule',
        html_url: 'https://www.federalregister.gov/articles/2014/06/26/2014-14703/federal-travel-regulation',
        publication_date: Date.parse('2014-06-26'),
        title: 'Federal Travel Regulation (FTR); Terms and Definitions for “Marriage,” “Spouse,” and “Domestic Partnership”' }
    end

    before do
      FederalRegisterDocumentApiParser.should_receive(:new).with(fake_options).and_return(parser)
    end

    it 'imports documents' do
      parser.should_receive(:each_document).and_yield(document_1_attributes).and_yield(document_2_attributes)
      FederalRegisterDocumentData.should_receive(:load_document).with(document_1_attributes)
      FederalRegisterDocumentData.should_receive(:load_document).with(document_2_attributes)

      FederalRegisterDocumentData.load_documents fake_options
    end
  end

  describe '.load_document' do
    fixtures :federal_register_agencies

    let(:fr_irs) { federal_register_agencies(:fr_irs) }
    let(:fr_noaa) { federal_register_agencies(:fr_noaa) }

    let!(:document) do
      doc = FederalRegisterDocument.new(document_number: '2012-14970',
                                        document_type: 'Proposed Rule',
                                        end_page: 36726,
                                        page_length: 1,
                                        publication_date: Date.parse('2012-06-20'),
                                        start_page: 36726,
                                        title: 'Open Meeting Original Title',
                                        html_url: 'https://www.federalregister.gov/articles/2012/06/20/2012-14970/original')
      doc.federal_register_agency_ids = [fr_irs.id]
      doc.save!
      doc
    end

    context 'when there is a document with matching document number' do
      it 'updates document attributes' do
        doc_attributes = { document_number: '2012-14970',
                           document_type: 'Rule',
                           end_page: 36726,
                           page_length: 1,
                           publication_date: Date.parse('2012-06-26'),
                           start_page: 36726,
                           title: 'Updated title',
                           html_url: 'https://www.federalregister.gov/articles/2012/06/20/2012-14970/updated',
                           federal_register_agency_ids: [fr_noaa.id] }.freeze

        loaded_doc = FederalRegisterDocumentData.load_document doc_attributes
        loaded_doc = FederalRegisterDocument.find loaded_doc.id

        loaded_doc.attributes.symbolize_keys.should include(doc_attributes.except(:federal_register_agency_ids))
        loaded_doc.federal_register_agency_ids.should == doc_attributes[:federal_register_agency_ids]
      end
    end

    context 'when the document is missing required attributes' do
      it 'returns nil' do
        doc_attributes = { document_type: 'Rule' }
        loaded_doc = FederalRegisterDocumentData.load_document doc_attributes

        loaded_doc.should be_nil
      end
    end
  end
end
