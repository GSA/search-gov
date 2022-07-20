require 'spec_helper'

describe FederalRegisterDocumentApiParser do
  fixtures :agencies, :federal_register_agencies

  describe '#each_document' do
    let(:fr_agency) { federal_register_agencies(:fr_irs) }
    let(:parser) { parser = described_class.new(federal_register_agency_ids: [fr_agency.id]) }
    let(:results) { double('results', next: nil) }

    before { expect(FederalRegister::Article).to receive(:search).and_return(results) }

    it 'extracts boolean fields' do
      significant = true

      unsanitized_document_1 = double('document',
                                    attributes: { 'agencies' => [{ 'id' => fr_agency.id }],
                                                  'significant' => significant })
      expect(results).to receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        expect(document[:significant]).to be true
      end
    end

    it 'extracts number fields' do
      end_page, page_length, start_page = 800, 2, 799
      unsanitized_document_1 = double('document',
                                    attributes: { 'agencies' => [{ 'id' => fr_agency.id }],
                                                  'end_page' => end_page,
                                                  'page_length' => page_length,
                                                  'start_page' => start_page })
      expect(results).to receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        expect(document[:end_page]).to eq end_page
        expect(document[:page_length]).to eq page_length
        expect(document[:start_page]).to eq start_page
      end
    end

    it 'parses date fields' do
      comments_close_on_str = '2020-08-08'.freeze
      effective_on_str = '2014-06-01'.freeze
      publication_date_str = '2014-01-01'.freeze
      unsanitized_document_1 = double('document',
                                    attributes: { 'agencies' => [{ 'id' => fr_agency.id }],
                                                  'comments_close_on' => comments_close_on_str,
                                                  'effective_on' => effective_on_str,
                                                  'publication_date' => publication_date_str })
      expect(results).to receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        expect(document[:comments_close_on]).to eq(Date.parse comments_close_on_str)
        expect(document[:effective_on]).to eq(Date.parse effective_on_str)
        expect(document[:publication_date]).to eq(Date.parse publication_date_str)
      end
    end

    it 'squishes string fields' do
      abstract = 'arbitrary   abstract with   spaces'.freeze
      docket_id = '  File No.   500-1  '
      document_number = ' 1111-3333 '.freeze
      html_url = ' http://www.federalregister.gov/doc.html  '
      title = 'arbitrary   title with   spaces'.freeze
      type = ' Notice '
      unsanitized_document_1 = double('document',
                                    attributes: { 'abstract' => abstract,
                                                  'agencies' => [{ 'id' => fr_agency.id }],
                                                  'docket_id' => docket_id,
                                                  'document_number' => document_number,
                                                  'html_url' => html_url,
                                                  'title' => title,
                                                  'type' => type })
      expect(results).to receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        expect(document[:abstract]).to eq 'arbitrary abstract with spaces'
        expect(document[:docket_id]).to eq 'File No. 500-1'
        expect(document[:document_number]).to eq '1111-3333'
        expect(document[:html_url]).to eq 'http://www.federalregister.gov/doc.html'
        expect(document[:title]).to eq 'arbitrary title with spaces'
        expect(document[:document_type]).to eq 'Notice'
      end
    end

    it 'extracts federal register agency ids' do
      document_number = ' 1111-3333 '.freeze
      title = 'arbitrary   title with   spaces'.freeze
      unsanitized_document_1 = double('document',
                                    attributes: { 'agencies' => [{ 'id' => 492 },
                                                                 { 'id' => 159 },
                                                                 { 'id' => 159, 'raw_name' => 'duplicate agency ID' },
                                                                 { 'raw_name' => 'agency without ID' }],
                                                  'document_number' => document_number,
                                                  'title' => title })
      expect(results).to receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        expect(document[:federal_register_agency_ids]).to eq [159, 492]
      end
    end
  end

end
